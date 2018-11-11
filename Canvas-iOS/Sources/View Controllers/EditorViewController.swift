import CanvasCore
import CanvasNative
import CanvasText
import UIKit

final class EditorViewController: UIViewController {

	// MARK: - Properties

	static let willCloseNotificationName = Notification.Name(rawValue: "EditorViewController.willCloseNotificationName")

	var canvas: Canvas

	let textController: TextController
	let textView: CanvasTextView

	private var lastSize: CGSize?
	var usingKeyboard = false

	private var scrollOffset: CGFloat?
	private var ignoreLocalSelectionChange = false

	private let titleView = TitleView()

	private var autocompleteEnabled = false {
		didSet {
			if oldValue == autocompleteEnabled {
				return
			}

			textView.autocapitalizationType = autocompleteEnabled ? .sentences : .none
			textView.autocorrectionType = autocompleteEnabled ? .default : .no
			textView.spellCheckingType = autocompleteEnabled ? .default : .no

			// Make the change actually take effect.
			if textView.isFirstResponder {
				ignoreLocalSelectionChange = true
				textView.resignFirstResponder()
				textView.becomeFirstResponder()
				ignoreLocalSelectionChange = false
			}
		}
	}

	// MARK: - Initializers

	init(canvas: Canvas = Canvas(), content: String? = nil) {
		self.canvas = canvas

		textController = TextController(theme: LightTheme(tintColor: Swatch.brand))

		let textView = CanvasTextView(frame: .zero, textContainer: textController.textContainer)
		textView.translatesAutoresizingMaskIntoConstraints = false
		self.textView = textView

		super.init(nibName: nil, bundle: nil)

		textController.displayDelegate = self
		textController.annotationDelegate = textView
		textView.textController = textController
		textView.delegate = self
		textView.formattingDelegate = self

		navigationItem.titleView = titleView

		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame),
											   name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(updatePreventSleep),
											   name: UserDefaults.didChangeNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(updatePreventSleep),
											   name: UIApplication.didBecomeActiveNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(updatePreventSleep),
											   name: UIDevice.batteryStateDidChangeNotification, object: nil)

		if let content = content {
			DispatchQueue.main.async { [weak self] in
				self?.textController.content = content
			}
		}
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - UIResponder

	override var canBecomeFirstResponder: Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand] {
		var commands: [UIKeyCommand] = [
			UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(dismissKeyboard)),
			UIKeyCommand(input: "w", modifierFlags: [.command], action: #selector(close),
						 discoverabilityTitle: LocalizedString.closeCommand.string)

//			UIKeyCommand(input: "b", modifierFlags: [.command], action: #selector(bold), discoverabilityTitle: LocalizedString.boldCommand.string),
//			UIKeyCommand(input: "i", modifierFlags: [.command], action: #selector(italic), discoverabilityTitle: LocalizedString.italicCommand.string),
//			UIKeyCommand(input: "d", modifierFlags: [.command], action: #selector(inlineCode), discoverabilityTitle: LocalizedString.inlineCodeCommand.string),
		]

		if textController.focusedBlock is Listable {
			commands += [
				UIKeyCommand(input: "]", modifierFlags: [.command], action: #selector(indent),
							 discoverabilityTitle: LocalizedString.indentCommand.string),
				UIKeyCommand(input: "\t", modifierFlags: [], action: #selector(indent)),
				UIKeyCommand(input: "[", modifierFlags: [.command], action: #selector(outdent),
							 discoverabilityTitle: LocalizedString.outdentCommand.string),
				UIKeyCommand(input: "\t", modifierFlags: [.shift], action: #selector(outdent)),

				UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [.command, .control],
							 action: #selector(swapLineUp),
							 discoverabilityTitle: LocalizedString.swapLineUpCommand.string),
				UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [.command, .control],
							 action: #selector(swapLineDown),
							 discoverabilityTitle: LocalizedString.swapLineDownCommand.string)
			]
		}

		let checkTitle: String
		if let block = textController.focusedBlock as? ChecklistItem, block.state == .checked {
			checkTitle = LocalizedString.markAsUncheckedCommand.string
		} else {
			checkTitle = LocalizedString.markAsCheckedCommand.string
		}

		let check = UIKeyCommand(input: "u", modifierFlags: [.command, .shift], action: #selector(self.check),
								 discoverabilityTitle: checkTitle)
		commands.append(check)

		commands += [
			UIKeyCommand(input: "k", modifierFlags: [.control, .shift], action: #selector(deleteLine),
						 discoverabilityTitle: LocalizedString.deleteLineCommand.string),
			UIKeyCommand(input: "\r", modifierFlags: [.command, .shift], action: #selector(insertLineBefore),
						 discoverabilityTitle: LocalizedString.insertLineBeforeCommand.string),
			UIKeyCommand(input: "\r", modifierFlags: [.command], action: #selector(insertLineAfter),
						 discoverabilityTitle: LocalizedString.insertLineAfterCommand.string)
		]

		return commands
	}

	// MARK: - UIViewController

	override var title: String? {
		didSet {
			titleView.title = title ?? ""
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		update(title: nil)

		view.backgroundColor = Swatch.white

		textView.delegate = self
		view.addSubview(textView)

		NSLayoutConstraint.activate([
			textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			textView.topAnchor.constraint(equalTo: view.topAnchor),
			textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])

		if traitCollection.forceTouchCapability == .available {
			registerForPreviewing(with: self, sourceView: textView)
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		// Prevent extra work if things didn't change. This method gets called more often than you'd expect.
		if view.bounds.size == lastSize {
			return
		}

		lastSize = view.bounds.size

		// Align title view
		if let navigationBar = navigationController?.navigationBar {
			var titleFrame = CGRect(
				x: 0,
				y: 0,

				// 200 seems to be when nav bar stops messing with alignment. ugh
				width: navigationBar.bounds.width - 200,
				height: navigationBar.bounds.height
			)
			titleFrame.origin.x = round((navigationBar.bounds.width - titleFrame.width) / 2)
			titleView.frame = titleFrame
		}

		let maxWidth: CGFloat = 640
		let horizontalPadding = max(16 - textView.textContainer.lineFragmentPadding,
									(textView.bounds.width - maxWidth) / 2)
		let topPadding = max(16, min(32, horizontalPadding - 4)) // Subtract 4 for title line height
		textView.textContainerInset = UIEdgeInsets(top: topPadding, left: horizontalPadding, bottom: 32,
												   right: horizontalPadding)
		textController.textContainerInset = textView.textContainerInset

		// Update insertion point
		if textView.isFirstResponder {
			ignoreLocalSelectionChange = true
			textView.resignFirstResponder()
			textView.becomeFirstResponder()
			ignoreLocalSelectionChange = false
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		UIDevice.current.isBatteryMonitoringEnabled = true
		updatePreventSleep()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if textController.currentDocument.isEmpty {
			textView.becomeFirstResponder()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		UIApplication.shared.isIdleTimerDisabled = false
		textView.resignFirstResponder()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		textController.traitCollection = traitCollection
	}

	// MARK: - Private

	@objc private func keyboardWillChangeFrame(notification: NSNotification?) {
		guard let notification = notification,
			let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else
		{
	    	return
    	}

		let frame = textView.frame.intersection(view.convert(value.cgRectValue, from: nil))
		var insets = textView.contentInset
		insets.bottom = frame.height

		textView.contentInset = insets
		textView.scrollIndicatorInsets = insets
	}

	@objc private func updatePreventSleep() {
		let application = UIApplication.shared

		switch SleepPrevention.currentPreference {
		case .never:
			application.isIdleTimerDisabled = false
		case .whilePluggedIn:
			let state = UIDevice.current.batteryState
			application.isIdleTimerDisabled = state == .charging || state == .full
		case .always:
			application.isIdleTimerDisabled = true
		}
	}

	func updateTitlePlaceholder() {
		let title = textController.currentDocument.blocks.first as? Title
		textView.placeholderLabel.isHidden = title.flatMap { $0.visibleRange.length > 0 } ?? false
	}

	private func updateTitleTypingAttributes() {
		if textView.selectedRange.location == 0 {
			textView.typingAttributes = textController.theme.titleAttributes
		}
	}

	private func updateAutoCompletion() {
		autocompleteEnabled = !textController.isCodeFocused
	}

	private func update(title newTitle: String?) {
		title = newTitle ?? LocalizedString.untitled.string
		updateTitlePlaceholder()
	}
}

extension EditorViewController: TintableEnvironment {
	var preferredTintColor: UIColor {
		return Swatch.brand
	}
}

extension EditorViewController: UIViewControllerPreviewingDelegate {
	func previewingContext(_ previewingContext: UIViewControllerPreviewing,
						   viewControllerForLocation location: CGPoint) -> UIViewController?
	{
		guard let textRange = textView.characterRange(at: location) else {
	    	return nil
    	}

		let range = NSRange(
			location: textView.offset(from: textView.beginningOfDocument, to: textRange.start),
			length: textView.offset(from: textRange.start, to: textRange.end)
		)

		let document = textController.currentDocument

		// TODO: Update for inline-markers
		let nodes = document.nodesIn(backingRange: document.backingRanges(presentationRange: range)[0])

		guard let index = nodes.index(where: { $0 is Link }),
			let link = nodes[index] as? Link,
			let url = link.URL(backingString: document.backingString),
			url.scheme == "http" || url.scheme == "https" else
		{
	    	return nil
    	}

		previewingContext.sourceRect = textView.firstRect(for: textRange)

		return WebViewController(url: url)
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing,
						   commit viewControllerToCommit: UIViewController)
	{
		present(viewControllerToCommit, animated: false, completion: nil)
	}
}

extension EditorViewController: UITextViewDelegate {
	func textViewDidChangeSelection(_ textView: UITextView) {
		scrollOffset = nil

		let selection = !textView.isFirstResponder && textView.selectedRange.length == 0 ? nil : textView.selectedRange
		textController.set(presentationSelectedRange: selection)
		updateTitleTypingAttributes()
		updateAutoCompletion()

		if NSEqualRanges(textView.selectedRange, NSRange(location: 0, length: 0)) {
			textView.typingAttributes = textController.theme.titleAttributes
		}
	}

	func textViewDidBeginEditing(_ textView: UITextView) {
		usingKeyboard = true
		updateTitleTypingAttributes()
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		if ignoreLocalSelectionChange {
			return
		}

		textController.set(presentationSelectedRange: nil)
	}

	func textViewDidChange(_ textView: UITextView) {
		textController.applyStyles()
	}

	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		scrollOffset = nil
	}
}

extension EditorViewController: TextControllerDisplayDelegate {
	func textController(_ textController: TextController, didUpdateSelectedRange selectedRange: NSRange) {
		// Defer to after editing completes or UITextView will misplace already queued edits
		DispatchQueue.main.async { [weak self] in
			guard let textView = self?.textView else {
	    	return
    	}

			if !NSEqualRanges(textView.selectedRange, selectedRange) {
				textView.selectedRange = selectedRange
			}

			if let previousPositionY = self?.scrollOffset, let position = textView.position(
				from: textView.beginningOfDocument, offset: textView.selectedRange.location)
			{
				let currentPositionY = textView.caretRect(for: position).minY
				textView.contentOffset = CGPoint(x: 0, y: textView.contentOffset.y + currentPositionY - previousPositionY)
				self?.scrollOffset = nil
			}

			self?.updateTitleTypingAttributes()
		}
	}

	func textController(_ textController: TextController, didUpdateTitle title: String?) {
		update(title: title)
	}

	func textController(_ textController: TextController, urlForImage block: Image) -> URL? {
		return block.url
	}

	func textControllerDidUpdateFolding(_ textController: TextController) {}

	func textControllerDidLayoutText(_ textController: TextController) {}
}

extension EditorViewController: CanvasTextViewFormattingDelegate {
	func textViewDidToggleBoldface(_ textView: CanvasTextView, sender: Any?) {
		bold()
	}

	func textViewDidToggleItalics(_ textView: CanvasTextView, sender: Any?) {
		italic()
	}
}
