//
//  TextController.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/2/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import WebKit
import OperationTransport
import CanvasNative

public protocol TextControllerConnectionDelegate: class {
	func textController(textController: TextController, willConnectWithWebView webView: WKWebView)
}

public protocol TextControllerSelectionDelegate: class {
	func textControllerDidUpdateSelectedRange(textController: TextController)
}


public final class TextController {

	// MARK: - Properties

	public weak var connectionDelegate: TextControllerConnectionDelegate?
	public weak var selectionDelegate: TextControllerSelectionDelegate?

	public let textStorage = TextStorage()
	public let layoutManager = LayoutManager()
	public let textContainer = TextContainer()

	public var presentationString: String {
		return textStorage.string
	}

	public var backingString: String {
		return canvasController.string
	}

	public var presentationSelectedRange: NSRange? {
		didSet {
			selectionDelegate?.textControllerDidUpdateSelectedRange(self)
		}
	}

	public var horizontalSizeClass: UserInterfaceSizeClass = .Unspecified
	public var theme: Theme

	private var transportController: TransportController?
	let canvasController = CanvasController()


	// MARK: - Initializers

	public init(theme: Theme = LightTheme()) {
		self.theme = theme

		// Setup Text Kit
		textContainer.textController = self
		layoutManager.textController = self
		layoutManager.addTextContainer(textContainer)
		textStorage.addLayoutManager(layoutManager)

		canvasController.delegate = self
	}


	// MARK: - OT

	public func connect(serverURL serverURL: NSURL, accessToken: String, organizationID: String, canvasID: String) {
		guard self.transportController == nil else { return }

		if connectionDelegate == nil {
			print("[TextController] WARNING: connectionDelegate is nil. If you don't add the web view from textController:willConnectWithWebView: to a view, Operation Transport won't work as expected.")
		}

		let transportController = TransportController(serverURL: serverURL, accessToken: accessToken, organizationID: organizationID, canvasID: canvasID)
		transportController.delegate = self
		transportController.connect()
		self.transportController = transportController
	}
}


extension TextController: TransportControllerDelegate {
	public func transportController(controller: TransportController, willConnectWithWebView webView: WKWebView) {
		connectionDelegate?.textController(self, willConnectWithWebView: webView)
	}

	public func transportController(controller: TransportController, didReceiveSnapshot text: String) {
		let bounds = NSRange(location: 0, length: canvasController.length)
		canvasController.replaceCharactersInRange(bounds, withString: text)
	}

	public func transportController(controller: TransportController, didReceiveOperation operation: Operation) {
		switch operation {
		case .Insert(let location, let string):
			let range = NSRange(location: Int(location), length: 0)
			canvasController.replaceCharactersInRange(range, withString: string)

		case .Remove(let location, let length):
			let range = NSRange(location: Int(location), length: Int(length))
			canvasController.replaceCharactersInRange(range, withString: "")
		}
	}

	public func transportController(controller: TransportController, didReceiveWebErrorMessage errorMessage: String?, lineNumber: UInt?, columnNumber: UInt?) {
		print("TransportController error \(errorMessage)")
	}

	public func transportController(controller: TransportController, didDisconnectWithErrorMessage errorMessage: String?) {
		print("TransportController disconnect \(errorMessage)")
	}
}


extension TextController: CanvasControllerDelegate {
	public func canvasControllerWillUpdateNodes(canvasController: CanvasController) {}

	public func canvasController(canvasController: CanvasController, didReplaceCharactersInPresentationStringInRange range: NSRange, withString string: String) {
		textStorage.replaceCharactersInRange(range, withString: string)

		if var selectedRange = presentationSelectedRange {
			selectedRange.location += (string as NSString).length
			selectedRange.location -= range.length
			presentationSelectedRange = selectedRange
		}

		let text = textStorage.string as NSString
		layoutManager.invalidateLayoutForCharacterRange(text.lineRangeForRange(range), actualCharacterRange: nil)
	}

	public func canvasController(canvasController: CanvasController, didInsertBlock block: BlockNode, atIndex index: Int) {
		print("Insert  \(block.dynamicType) at \(index)")
	}

	public func canvasController(canvasController: CanvasController, didRemoveBlock block: BlockNode, atIndex index: Int) {
		print("Remove  \(block.dynamicType) at \(index)")
	}

	public func canvasController(canvasController: CanvasController, didReplaceContentForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode) {
		print("Replace \(after.dynamicType) at \(index)")
	}

	public func canvasController(canvasController: CanvasController, didUpdateLocationForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode) {
		print("Update  \(after.dynamicType) at \(index)")
	}

	public func canvasControllerDidUpdateNodes(controller: CanvasController) {
		print("\n---------------------------------------\n")
	}
}
