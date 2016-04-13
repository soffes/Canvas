//
//  DocumentController.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/18/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol DocumentControllerDelegate: class {
	// After this message, `document` will be the new value
	func documentControllerWillUpdateDocument(controller: DocumentController)

	// This will be called before all other messages.
	func documentController(controller: DocumentController, didReplaceCharactersInPresentationStringInRange range: NSRange, withString string: String)

	// The index will be relative to the blocks array before the change (similar to UITableView).
	func documentController(controller: DocumentController, didInsertBlock block: BlockNode, atIndex index: Int)

	func documentController(controller: DocumentController, didRemoveBlock block: BlockNode, atIndex index: Int)

	// The block's content changed. `before` and `after` will always be the same type.
	func documentController(controller: DocumentController, didReplaceContentForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode)

	// The block's metadata changed. `before` and `after` will always be the same type.
	func documentController(controller: DocumentController, didUpdateLocationForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode)

	// Changes to `document` are complete
	func documentControllerDidUpdateDocument(controller: DocumentController)
}


public final class DocumentController {

	// MARK: - Properties

	public weak var delegate: DocumentControllerDelegate?

	public private(set) var document: Document


	// MARK: - Initializers

	public init(backingString: String, delegate: DocumentControllerDelegate? = nil) {
		self.document = Document(backingString: backingString)
		self.delegate = delegate
	}

	public init(document: Document? = nil, delegate: DocumentControllerDelegate? = nil) {
		self.document = document ?? Document()
		self.delegate = delegate
	}


	// MARK: - Changing Text

	public func replaceCharactersInRange(range: NSRange, withString string: String) {
		// Notifiy the delegate we have a change
		delegate?.documentControllerWillUpdateDocument(self)

		// Get the change
		let change = document.replaceCharactersInRange(range, withString: string)

		// Notify about presentation string change
		if let presentationChange = change.presentationStringChange {
			delegate?.documentController(self, didReplaceCharactersInPresentationStringInRange: presentationChange.range, withString: presentationChange.string)
		}

		// Notify about AST changes
		change.blockChanges.forEach(sendDelegateMessage)

		// Set the new document
		document = change.after

		// Notifiy the delegate that we're done.
		delegate?.documentControllerDidUpdateDocument(self)
	}


	// MARK: - Delegate Calls

	private func sendDelegateMessage(message: BlockChange) {
		switch message {
		case .Insert(let block, let index):
			delegate?.documentController(self, didInsertBlock: block, atIndex: index)
		case .Remove(let block, let index):
			delegate?.documentController(self, didRemoveBlock: block, atIndex: index)
		case .Replace(let before, let index, let after):
			if before.dynamicType == after.dynamicType {
				delegate?.documentController(self, didReplaceContentForBlock: before, atIndex: index, withBlock: after)
			} else {
				delegate?.documentController(self, didRemoveBlock: before, atIndex: index)
				delegate?.documentController(self, didInsertBlock: after, atIndex: index)
			}
		case .Update(let before, let index, let after):
			delegate?.documentController(self, didUpdateLocationForBlock: before, atIndex: index, withBlock: after)
		}
	}
}
