//
//  DocumentController.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/18/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

/// DocumentController delegate for notifications about changes to the owned document.  You can not rely upon these
/// messages to keep a parallel array in sync with the backing model. They are intended to be used for keeping
/// associated information in sync. After `documentControllerDidUpdateDocument` is called, all of the models will
/// reflect the new state.
public protocol DocumentControllerDelegate: class {
	// After this message, `document` will be the new value
	func documentControllerWillUpdateDocument(controller: DocumentController)

	// This will be called before all other messages.
	func documentController(controller: DocumentController, didReplaceCharactersInPresentationStringInRange range: NSRange, withString string: String)

	func documentController(controller: DocumentController, didInsertBlock block: BlockNode, atIndex index: Int)

	func documentController(controller: DocumentController, didRemoveBlock block: BlockNode, atIndex index: Int)

	// Changes to `document` are complete
	func documentControllerDidUpdateDocument(controller: DocumentController)
}


public final class DocumentController {

	// MARK: - Properties

	public weak var delegate: DocumentControllerDelegate?

	public private(set) var document = Document()


	// MARK: - Initializers

	public init(backingString: String, delegate: DocumentControllerDelegate? = nil) {
		self.document = Document(backingString: backingString)
		self.delegate = delegate

		let change = Document().replaceCharactersInRange(NSRange(location: 0, length: 0), withString: document.backingString)
		processChange(change)
	}

	public init(document: Document? = nil, delegate: DocumentControllerDelegate? = nil) {
		self.document = document ?? Document()
		self.delegate = delegate

		if let document = document {
			let change = Document().replaceCharactersInRange(NSRange(location: 0, length: 0), withString: document.backingString)
			processChange(change)
		}
	}


	// MARK: - Changing Text

	public func replaceCharactersInRange(range: NSRange, withString string: String) {
		let change = document.replaceCharactersInRange(range, withString: string)
		processChange(change)
	}


	// MARK: - Private

	private func processChange(change: DocumentChange) {
		// Notifiy the delegate we have a change
		delegate?.documentControllerWillUpdateDocument(self)

		// Notify about presentation string change
		if let presentationChange = change.presentationStringChange {
			delegate?.documentController(self, didReplaceCharactersInPresentationStringInRange: presentationChange.range, withString: presentationChange.replacement)
		}

		// Notify about AST changes
		if let blockChange = change.blockChange {
			// Remove
			for i in blockChange.range.reverse() {
				delegate?.documentController(self, didRemoveBlock: change.before.blocks[i], atIndex: i)
			}

			// Insert
			for (i, block) in blockChange.replacement.enumerate() {
				delegate?.documentController(self, didInsertBlock: block, atIndex: blockChange.range.startIndex + i)
			}
		}

		// Set the new document
		document = change.after

		// Notifiy the delegate that we're done.
		delegate?.documentControllerDidUpdateDocument(self)
	}
}
