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
		textView = UITextView(frame: .zero, textContainer: textController.textContainer)
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.alwaysBounceVertical = true
		textView.font = .systemFontOfSize(18)

		super.init(nibName: nil, bundle: nil)

		textController.connectionDelegate = self
		textController.selectionDelegate = self
		textController.annotationDelegate = self
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

		textController.connect(
			serverURL: NSURL(string: "wss://realtime.usecanvas.com")!,
			accessToken: NSUserDefaults.standardUserDefaults().stringForKey("AccessToken")!,
			organizationID: "b29c5091-3959-4ca8-a39e-c3159f5f06c5",
			canvasID: "59S18UczqJcw0rx1AsVaTD" //"3n2OAeAec2vDDQxmx6pijZ"
		)
	}

	override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		textController.horizontalSizeClass = traitCollection.horizontalSizeClass
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


extension ViewController: TextControllerAnnotationDelegate {
	func textController(textController: TextController, willAddAnnotation annotation: View) {
		textView.insertSubview(annotation, atIndex: 0)
	}
}
