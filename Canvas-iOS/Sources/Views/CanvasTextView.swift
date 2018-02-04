import CanvasCore
import CanvasNative
import CanvasText
import UIKit

protocol CanvasTextViewFormattingDelegate: class {
	func textViewDidToggleBoldface(_ textView: CanvasTextView, sender: Any?)
	func textViewDidToggleItalics(_ textView: CanvasTextView, sender: Any?)
}

final class CanvasTextView: TextView {

    // MARK: - Properties

	weak var textController: TextController? {
		didSet {
			guard let theme = textController?.theme else {
            return
        }

			var attributes = theme.titleAttributes
			attributes[.foregroundColor] = theme.titlePlaceholderColor

			placeholderLabel.attributedText = NSAttributedString(
				string: LocalizedString.canvasTitlePlaceholder.string,
				attributes: attributes
			)
		}
	}

	weak var formattingDelegate: CanvasTextViewFormattingDelegate?

	let dragGestureRecognizer: UIPanGestureRecognizer
	let dragThreshold: CGFloat = 60
	var dragContext: DragContext?

	let placeholderLabel: UILabel = {
		let label = UILabel()
		label.isUserInteractionEnabled = false
		label.isHidden = true
		return label
	}()

    // MARK: - Initializers

	override init(frame: CGRect, textContainer: NSTextContainer?) {
		dragGestureRecognizer = UIPanGestureRecognizer()

		super.init(frame: frame, textContainer: textContainer)

//		allowsEditingTextAttributes = true
		alwaysBounceVertical = true
		keyboardDismissMode = .interactive
		backgroundColor = .clear

		registerGestureRecognizers()

		managedSubviews.insert(placeholderLabel)
		addSubview(placeholderLabel)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - UIResponder

	override func toggleBoldface(_ sender: Any?) {
		formattingDelegate?.textViewDidToggleBoldface(self, sender: sender)
	}

	override func toggleItalics(_ sender: Any?) {
		formattingDelegate?.textViewDidToggleItalics(self, sender: sender)
	}

	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		// Disable underline
		if action == #selector(toggleUnderline) {
			return false
		}

		return super.canPerformAction(action, withSender: sender)
	}

    // MARK: - UIView

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutPlaceholder()
	}

	override func tintColorDidChange() {
		super.tintColorDidChange()

		textController?.set(tintColor: tintColor)
	}

    // MARK: - Private

	private func layoutPlaceholder() {
		placeholderLabel.sizeToFit()

		var frame = placeholderLabel.frame
		frame.origin.x = textContainerInset.left
		frame.origin.y = textContainerInset.top
		placeholderLabel.frame = frame
	}
}

extension CanvasTextView: TextControllerAnnotationDelegate {
	func textController(_ textController: TextController, willAddAnnotation annotation: Annotation) {
		annotation.view.backgroundColor = .clear
		managedSubviews.insert(annotation.view)
		insertSubview(annotation.view, at: 0)
	}

	func textController(_ textController: TextController, willRemoveAnnotation annotation: Annotation) {
		managedSubviews.remove(annotation.view)
	}
}
