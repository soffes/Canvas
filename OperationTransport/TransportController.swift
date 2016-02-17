//
//  TransportController.swift
//  OperationTransport
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import WebKit

public protocol TransportControllerDelegate: class {
	func transportController(controller: TransportController, didReceiveSnapshot text: String)
	func transportController(controller: TransportController, didReceiveOperation operation: Operation)
	func transportController(controller: TransportController, didReceiveWebErrorMessage errorMessage: String?, lineNumber: UInt?, columnNumber: UInt?)
	func transportController(controller: TransportController, didDisconnectWithErrorMessage errorMessage: String?)
}

private let indexHTML: String? = {
	let bundle = NSBundle(forClass: TransportController.self)
	guard let editorPath = bundle.pathForResource("index", ofType: "html"),
		html = try? String(contentsOfFile: editorPath, encoding: NSUTF8StringEncoding)
	else { return nil }

	return html
}()


public class TransportController: NSObject {
	
	// MARK: - Properties

	public let serverURL: NSURL
	private let accessToken: String
	public let organizationID: String
	public let canvasID: String
	public weak var delegate: TransportControllerDelegate?

	var webView: WKWebView!

	
	// MARK: - Initializers
	
	public init(serverURL: NSURL, accessToken: String, organizationID: String, canvasID: String) {
		self.serverURL = serverURL
		self.accessToken = accessToken
		self.organizationID = organizationID
		self.canvasID = canvasID
		
		super.init()

		let configuration = WKWebViewConfiguration()
		configuration.allowsAirPlayForMediaPlayback = false

		#if !os(OSX)
			configuration.allowsInlineMediaPlayback = false
			configuration.allowsPictureInPictureMediaPlayback = false
		#endif

		// Setup script handler
		let userContentController = WKUserContentController()
		userContentController.addScriptMessageHandler(self, name: "share")

		// Connect
		let js = "Canvas.connect('\(serverURL.absoluteString)', '\(accessToken)', '\(organizationID)', '\(canvasID)');"
		userContentController.addUserScript(WKUserScript(source: js, injectionTime: .AtDocumentEnd, forMainFrameOnly: true))
		configuration.userContentController = userContentController

		// Load file
		webView = WKWebView(frame: .zero, configuration: configuration)

		#if !os(OSX)
			webView.scrollView.scrollsToTop = false
		#endif

	}


	// MARK: - Connecting

	public func connect() {
		guard let html = indexHTML else { return }
		webView.loadHTMLString(html, baseURL: serverURL)
	}
	
	
	// MARK: - Operations
	
	public func submitOperation(operation: Operation) {
		switch operation {
		case .Insert(let location, let string): insert(location: location, string: string)
		case .Remove(let location, let length): remove(location: location, length: length)
		}
	}

	
	// MARK: - Private
	
	private func insert(location location: UInt, string: String) {
		guard let data = try? NSJSONSerialization.dataWithJSONObject([string], options: []),
			json = String(data: data, encoding: NSUTF8StringEncoding)
		else { return }
		
		webView.evaluateJavaScript("Canvas.insert(\(location), \(json)[0]);", completionHandler: nil)
	}
	
	private func remove(location location: UInt, length: UInt) {
		webView.evaluateJavaScript("Canvas.remove(\(location), \(length));", completionHandler: nil)
	}
}


extension TransportController: WKScriptMessageHandler {
	public func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage scriptMessage: WKScriptMessage) {
		guard let dictionary = scriptMessage.body as? [String: AnyObject],
			message = TransportMessage(dictionary: dictionary)
		else {
			print("[TransportController] Unknown message: \(scriptMessage.body)")
			return
		}

		switch message {
		case .Operation(let operation):
			delegate?.transportController(self, didReceiveOperation: operation)
		case .Snapshot(let content):
			delegate?.transportController(self, didReceiveSnapshot: content)
		case .Disconnect(let errorMessage):
			delegate?.transportController(self, didDisconnectWithErrorMessage: errorMessage)
		case .Error(let errorMessage, let lineNumber, let columnNumber):
			delegate?.transportController(self, didReceiveWebErrorMessage: errorMessage, lineNumber: lineNumber, columnNumber: columnNumber)
		}
	}
}
