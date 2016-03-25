//
//  ViewController.swift
//  Example
//
//  Created by Sam Soffes on 2/17/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import WebKit
import CanvasText

class ViewController: UIViewController {

	// MARK: - Properties

	let textController = TextController()
	let textView: UITextView

	private var ignoreSelectionChange = false


	// MARK: - Initializers

	override init(nibName: String?, bundle: NSBundle?) {
		let textView = TextView(frame: .zero, textContainer: textController.textContainer)
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.alwaysBounceVertical = true
		self.textView = textView
		
		super.init(nibName: nil, bundle: nil)

		textController.connectionDelegate = self
		textController.selectionDelegate = self
		textController.annotationDelegate = textView
		textView.delegate = self
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIViewController

	override func loadView() {
		view = textView
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Example"

		guard let accessToken = NSUserDefaults.standardUserDefaults().stringForKey("AccessToken") else {
			fatalError("Access token is not set. Please set your access token in AppDelegate.swift and rerun the app.")
		}

		// Blank "31fst7N9L4W5EdALDkLiaz"
		// Demo  "59S18UczqJcw0rx1AsVaTD"
		// Long  "3n2OAeAec2vDDQxmx6pijZ"

		textController.connect(
			serverURL: NSURL(string: "wss://realtime.usecanvas.com")!,
			accessToken: accessToken,
			organizationID: "b29c5091-3959-4ca8-a39e-c3159f5f06c5",
			canvasID: "3n2OAeAec2vDDQxmx6pijZ"
		)
	}

	override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		textController.horizontalSizeClass = traitCollection.horizontalSizeClass
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		let maxWidth: CGFloat = 640
		let padding = max(16 - textView.textContainer.lineFragmentPadding, (textView.bounds.width - maxWidth) / 2)
		textView.textContainerInset = UIEdgeInsets(top: 16, left: padding, bottom: 32, right: padding)
		textController.textContainerInset = textView.textContainerInset
	}
}


extension ViewController: UITextViewDelegate {
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		ignoreSelectionChange = true
		return true
	}

	func textViewDidChangeSelection(textView: UITextView) {
		textController.presentationSelectedRange = textView.isFirstResponder() ? textView.selectedRange : nil
	}

	func textViewDidEndEditing(textView: UITextView) {
		textController.presentationSelectedRange = nil
	}
}


extension ViewController: TextControllerSelectionDelegate {
	func textControllerDidUpdateSelectedRange(textController: TextController) {
		if ignoreSelectionChange {
			ignoreSelectionChange = false
			return
		}

		guard let selectedRange = textController.presentationSelectedRange else {
			textView.selectedRange = NSRange(location: 0, length: 0)
			return
		}

		if !NSEqualRanges(textView.selectedRange, selectedRange) {
			textView.selectedRange = selectedRange
		}
	}
}


extension ViewController: TextControllerConnectionDelegate {
	func textController(textController: TextController, willConnectWithWebView webView: WKWebView) {
		webView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
		view.addSubview(webView)
	}
}
