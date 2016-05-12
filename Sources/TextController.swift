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
	func textControllerDidConnect(textController: TextController)
	func textController(textController: TextController, didReceiveWebErrorMessage errorMessage: String?, lineNumber: UInt?, columnNumber: UInt?)
	func textController(textController: TextController, didDisconnectWithErrorMessage errorMessage: String?)
}

public protocol TextControllerDisplayDelegate: class {
	func textController(textController: TextController, didUpdateSelectedRange selectedRange: NSRange)
	func textController(textController: TextController, didUpdateTitle title: String?)
	func textControllerWillProcessRemoteEdit(textController: TextController)
	func textControllerDidProcessRemoteEdit(textController: TextController)
	func textController(textController: TextController, URLForImage block: Image) -> NSURL?
}

public protocol TextControllerAnnotationDelegate: class {
	func textController(textController: TextController, willAddAnnotation annotation: Annotation)
	func textController(textController: TextController, willRemoveAnnotation annotation: Annotation)
}


public final class TextController {

	// MARK: - Properties

	public weak var connectionDelegate: TextControllerConnectionDelegate?
	public weak var displayDelegate: TextControllerDisplayDelegate?
	public weak var annotationDelegate: TextControllerAnnotationDelegate?

	let _textStorage = TextStorage()
	public var textStorage: NSTextStorage {
		return _textStorage
	}

	private let _layoutManager = LayoutManager()
	public var layoutManager: NSLayoutManager {
		return _layoutManager
	}

	private let _textContainer = TextContainer()
	public var textContainer: NSTextContainer {
		return _textContainer
	}

	public var presentationString: String {
		return textStorage.string
	}

	public private(set) var presentationSelectedRange: NSRange?

	public var focusedBlock: BlockNode? {
		let selection = presentationSelectedRange
		let document = currentDocument
		return selection.flatMap { document.blockAt(presentationLocation: $0.location) }
	}

	public var textContainerInset: EdgeInsets = .zero {
		didSet {
			annotationsController.textContainerInset = textContainerInset
		}
	}

	public var theme: Theme
	public var traitCollection = UITraitCollection(horizontalSizeClass: .Unspecified) {
		didSet {
			traitCollectionDidChange(oldValue)
		}
	}

	private var transportController: TransportController?
	private let annotationsController: AnnotationsController
	private let imagesController = ImagesController()

	let documentController = DocumentController()

	public var currentDocument: Document {
		return documentController.document
	}

	let serverURL: NSURL
	let accessToken: String
	let organizationID: String
	let canvasID: String

	private var needsTitle = false


	// MARK: - Initializers

	public init(serverURL: NSURL, accessToken: String, organizationID: String, canvasID: String, theme: Theme = LightTheme()) {
		self.serverURL = serverURL
		self.accessToken = accessToken
		self.organizationID = organizationID
		self.canvasID = canvasID
		self.theme = theme

		annotationsController = AnnotationsController(theme: theme)
		annotationsController.textController = self
		annotationsController.delegate = self

		// Configure Text Kit
		_textContainer.textController = self
		_layoutManager.textController = self
		_layoutManager.layoutDelegate = self
		_textStorage.textController = self
		_textStorage.customDelegate = self
		layoutManager.addTextContainer(textContainer)
		textStorage.addLayoutManager(layoutManager)

		documentController.delegate = self
	}


	// MARK: - OT

	public func connect() {
		if connectionDelegate == nil {
			print("[TextController] WARNING: connectionDelegate is nil. If you don't add the web view from textController:willConnectWithWebView: to a view, Operation Transport won't work as expected.")
		}

		let transportController = TransportController(serverURL: serverURL, accessToken: accessToken, organizationID: organizationID, canvasID: canvasID)
		transportController.delegate = self
		transportController.connect()
		self.transportController = transportController
	}

	public func disconnect(reason reason: String?) {
		transportController?.disconnect(reason: reason)
		transportController = nil
	}
	
	
	// MARK: - Traits
	
	public func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		layoutAttachments()
		annotationsController.horizontalSizeClass = traitCollection.horizontalSizeClass
	}


	// MARK: - Selection

	// Update from Text View
	public func setPresentationSelectedRange(range: NSRange?) {
		setPresentationSelectedRange(range, updateTextView: false)
	}

	// Update from Text Controller
	func setPresentationSelectedRange(range: NSRange?, updateTextView: Bool) {
		presentationSelectedRange = range

		if updateTextView, let range = range {
			displayDelegate?.textController(self, didUpdateSelectedRange: range)
		}
	}


	// MARK: - Private

	private func layoutAttachments() {
		var styles = [Style]()
		
		for block in currentDocument.blocks {
			guard let block = block as? Attachable,
				style = attachmentStyle(block: block)
			else { continue }
			
			styles.append(style)
		}
		
		_textStorage.addStyles(styles)
		_textStorage.applyStyles()
	}
	
	private func stylesForBlock(block: BlockNode) -> [Style] {
		var range = currentDocument.presentationRange(backingRange: block.visibleRange)
		if range.location > 0 {
			range.location -= 1
			range.length += 1
		}

		let blockStyle = Style(
			range: range,
			attributes: theme.attributes(block: block)
		)

		var styles = [blockStyle]

		if let container = block as? NodeContainer, font = blockStyle.attributes[NSFontAttributeName] as? Font {
			styles += stylesForSpans(container.subnodes, currentFont: font)
		}

		return styles
	}

	private func stylesForSpans(spans: [SpanNode], currentFont: Font) -> [Style] {
		var styles = [Style]()

		for span in spans {
			guard let attributes = theme.attributes(span: span, currentFont: currentFont) else { continue }

			let style = Style(
				range: currentDocument.presentationRange(backingRange: span.visibleRange),
				attributes: attributes
			)
			styles.append(style)

			let font = attributes[NSFontAttributeName] as? Font ?? currentFont
			let foldableAttributes = theme.foldingAttributes(currentFont: font)

			// Foldable attributes
			if let foldable = span as? Foldable {
				// Forward the background color
				var attrs = foldableAttributes
				attrs[NSBackgroundColorAttributeName] = attributes[NSBackgroundColorAttributeName]

				for backingRange in foldable.foldableRanges {
					let style = Style(
						range: currentDocument.presentationRange(backingRange: backingRange),
						attributes: attrs
					)
					styles.append(style)
				}
			}

			// Special case for link URL and title. Maybe we should consider having Themes emit Styles instead of
			// attributes or at least have a style controller for all of this logic.
			if let link = span as? Link {
				// TODO: Derive from theme
				var attrs = foldableAttributes
				attrs[NSForegroundColorAttributeName] = Color(red: 0.420, green: 0.420, blue: 0.447, alpha: 1)

				styles.append(Style(range: currentDocument.presentationRange(backingRange: link.urlRange), attributes: attrs))

				if let title = link.title {
					styles.append(Style(range: currentDocument.presentationRange(backingRange: title.textRange), attributes: attrs))
				}
			}

			if let container = span as? NodeContainer {
				styles += stylesForSpans(container.subnodes, currentFont: font)
			}
		}

		return styles
	}

	private func submitOperations(backingRange backingRange: NSRange, string: String) {
		guard let transportController = transportController else {
			print("[TextController] WARNING: Tried to submit an operation without a connection.")
			return
		}

		// Insert
		if backingRange.length == 0 {
			transportController.submitOperation(.Insert(location: UInt(backingRange.location), string: string))
			return
		}

		// Remove
		transportController.submitOperation(.Remove(location: UInt(backingRange.location), length: UInt(backingRange.length)))

		// Insert after removing
		if backingRange.length > 0 {
			transportController.submitOperation(.Insert(location: UInt(backingRange.location), string: string))
		}
	}
	
	private func attachmentStyle(block block: Attachable) -> Style? {
		let attachment: NSTextAttachment
		
		// Horizontal rule
		if block is HorizontalRule {
			guard let image = HorizontalRuleAttachment.image(theme: theme) else { return nil }
			
			attachment = NSTextAttachment()
			attachment.image = image
			attachment.bounds = CGRect(x: 0, y: 0, width: textContainer.size.width, height: HorizontalRuleAttachment.height)
		}
		
		// Image
		else if let block = block as? Image {
			let URL = displayDelegate?.textController(self, URLForImage: block) ?? block.url
			
			let width = floor(textContainer.size.width)
			let size = attachmentSize(imageSize: block.size ?? CGSize(width: width, height: 300))
			
			attachment = NSTextAttachment()
			attachment.image = imagesController.fetchImage(
				ID: block.identifier,
				URL: URL,
				size: size,
				scale: traitCollection.displayScale,
				completion: updateImageAttachment
			)
			attachment.bounds = CGRect(origin: .zero, size: size)
		}
		
		// Missing attachment
		else {
			print("WARNING: Missing attachment for block \(block)")
			return nil
		}
		
		let range = currentDocument.presentationRange(backingRange: block.visibleRange)
		return Style(range: range, attributes: [
			NSAttachmentAttributeName: attachment
		])
	}
	
	private func attachmentSize(imageSize imageSize: CGSize) -> CGSize {
		let width = floor(textContainer.size.width)
		var size = imageSize
		
		size.height = floor(width * size.height / size.width)
		size.width = width
		
		return size
	}
	
	private func blockForImageID(ID: String) -> Image? {
		for block in currentDocument.blocks {
			if let image = block as? Image where image.identifier == ID {
				return image
			}
		}
		
		return nil
	}
	
	private func updateImageAttachment(ID ID: String, image: UIImage?) {
		guard let image = image, block = blockForImageID(ID) else { return }
		
		let attachment = NSTextAttachment()
		attachment.image = image
		attachment.bounds = CGRect(origin: .zero, size: attachmentSize(imageSize: image.size))
		
		let range = currentDocument.presentationRange(backingRange: block.visibleRange)
		let style = Style(range: range, attributes: [
			NSAttachmentAttributeName: attachment
		])
		
		_textStorage.addStyles([style])
		_textStorage.applyStyles()
	}
}


extension TextController: TransportControllerDelegate {
	public func transportController(controller: TransportController, willConnectWithWebView webView: WKWebView) {
		connectionDelegate?.textController(self, willConnectWithWebView: webView)
	}

	public func transportController(controller: TransportController, didReceiveSnapshot text: String) {
		let bounds = NSRange(location: 0, length: (currentDocument.backingString as NSString).length)

		// Ensure we have a valid document
		var string = text
		if string.isEmpty {
			string = Title.nativeRepresentation()
			submitOperations(backingRange: bounds, string: string)
		}

		setNeedsTitleUpdate()
		displayDelegate?.textControllerWillProcessRemoteEdit(self)
		documentController.replaceCharactersInRange(bounds, withString: string)
		connectionDelegate?.textControllerDidConnect(self)
		displayDelegate?.textControllerDidProcessRemoteEdit(self)
	}

	public func transportController(controller: TransportController, didReceiveOperation operation: Operation) {
		displayDelegate?.textControllerWillProcessRemoteEdit(self)

		switch operation {
		case .Insert(let location, let string):
			let range = NSRange(location: Int(location), length: 0)
			documentController.replaceCharactersInRange(range, withString: string)

		case .Remove(let location, let length):
			let range = NSRange(location: Int(location), length: Int(length))
			documentController.replaceCharactersInRange(range, withString: "")
		}

		displayDelegate?.textControllerDidProcessRemoteEdit(self)
	}

	public func transportController(controller: TransportController, didReceiveWebErrorMessage errorMessage: String?, lineNumber: UInt?, columnNumber: UInt?) {
		print("TransportController error \(errorMessage)")
		connectionDelegate?.textController(self, didReceiveWebErrorMessage: errorMessage, lineNumber: lineNumber, columnNumber: columnNumber)
	}

	public func transportController(controller: TransportController, didDisconnectWithErrorMessage errorMessage: String?) {
		print("TransportController disconnect \(errorMessage)")
		connectionDelegate?.textController(self, didDisconnectWithErrorMessage: errorMessage)
	}
}


extension TextController: DocumentControllerDelegate {
	public func documentControllerWillUpdateDocument(controller: DocumentController) {
		textStorage.beginEditing()
	}

	public func documentController(controller: DocumentController, didReplaceCharactersInPresentationStringInRange range: NSRange, withString string: String) {
		_textStorage.actuallyReplaceCharactersInRange(range, withString: string)

		guard let selection = presentationSelectedRange else { return }

		let length = (string as NSString).length
		let adjusted = SelectionController.adjust(selection: selection, replacementRange: range, replacementLength: length)
		setPresentationSelectedRange(adjusted, updateTextView: true)
	}

	public func documentController(controller: DocumentController, didInsertBlock block: BlockNode, atIndex index: Int) {
		annotationsController.insert(block: block, index: index)
		_textStorage.addStyles(stylesForBlock(block))

		var range = controller.document.presentationRange(backingRange: block.visibleRange)
		if range.location > 0 {
			range.location -= 1
			range.length += 1
		}

		if range.max < (controller.document.presentationString as NSString).length {
			range.length += 1
		}

		_textStorage.invalidRange(range)
		
		if let block = block as? Attachable, style = attachmentStyle(block: block) {
			_textStorage.addStyles([style])
		}

		if index == 0 {
			setNeedsTitleUpdate()
		}
	}

	public func documentController(controller: DocumentController, didRemoveBlock block: BlockNode, atIndex index: Int) {
		annotationsController.remove(block: block, index: index)

		if index == 0 {
			setNeedsTitleUpdate()
		}
	}

	public func documentControllerDidUpdateDocument(controller: DocumentController) {
		textStorage.endEditing()

		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			self?._textStorage.applyStyles()
			self?._textStorage.invalidateLayoutIfNeeded()
		}

		updateTitleIfNeeded(controller)
	}

	private func refreshAnnotations() {
		let blocks = currentDocument.blocks

		// Refresh models
		for (i, block) in blocks.enumerate() {
			guard let block = block as? Annotatable else { continue }
			annotationsController.update(block: block, index: i)
		}

		// Layout
		annotationsController.layoutAnnotations()
	}

	private func setNeedsTitleUpdate() {
		needsTitle = true
	}

	private func updateTitleIfNeeded(controller: DocumentController) {
		if !needsTitle {
			return
		}

		displayDelegate?.textController(self, didUpdateTitle: controller.document.title)
		needsTitle = false
	}
}


extension TextController: AnnotationsControllerDelegate {
	func annotationsController(annotationsController: AnnotationsController, willAddAnnotation annotation: Annotation) {
		annotationDelegate?.textController(self, willAddAnnotation: annotation)
	}

	func annotationsController(annotationsController: AnnotationsController, willRemoveAnnotation annotation: Annotation) {
		annotationDelegate?.textController(self, willRemoveAnnotation: annotation)
	}
}


extension TextController: TextStorageDelegate {
	func textStorage(textStorage: TextStorage, didReplaceCharactersInRange range: NSRange, withString string: String) {		
		let document = currentDocument
		var presentationRange = range
		var backingRange = document.backingRange(presentationRange: presentationRange)
		var replacement = string

		// Return completion
		if string == "\n" {
			// Continue the previous node
			if let block = document.blockAt(backingLocation: backingRange.location) as? ReturnCompletable {
				// Bust out of completion
				if block.visibleRange.length == 0 {
					backingRange = block.range
					replacement = ""
				} else {
					// Complete the node
					if let block = block as? NativePrefixable {
						replacement += (document.backingString as NSString).substringWithRange(block.nativePrefixRange)

						// Make checkboxes unchecked by default
						replacement = replacement.stringByReplacingOccurrencesOfString("- [x] ", withString: "- [ ] ")
					}
				}
			}

			// Code block
			else {
				let text = document.backingString as NSString
				let lineRange = text.lineRangeForRange(backingRange)
				let line = text.substringWithRange(lineRange)

				// TODO: Support language
				if line.hasPrefix("```") {
					backingRange = lineRange.union(backingRange)
					replacement = CodeBlock.nativeRepresentation() + "\n"
				}
			}
		}

		edit(backingRange: backingRange, replacement: replacement)

		backingRange.length = (replacement as NSString).length
		presentationRange = document.presentationRange(backingRange: backingRange)
		processMarkdownShortcuts(presentationRange)
	}

	func textStorageDidProcessEditing(textStorage: TextStorage) {
		if textStorage.isEditing {
			return
		}

		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			self?.refreshAnnotations()
		}
	}

	// Commit the edit to DocumentController and submit the operation to OT. This doesn't go through the text system so
	// things like markdown shortcuts and return completion don't run on this change. Ideally, this will only be used
	// by the text storage delegate or changes made to non-visible portions of the backing string (like block or
	// indentation changes).
	func edit(backingRange backingRange: NSRange, replacement: String) {
		documentController.replaceCharactersInRange(backingRange, withString: replacement)
		submitOperations(backingRange: backingRange, string: replacement)
	}
}


extension TextController: LayoutManagerDelegate {
	func layoutManager(layoutManager: NSLayoutManager, textContainerChangedGeometry textContainer: NSTextContainer) {
		layoutAttachments()
	}
}
