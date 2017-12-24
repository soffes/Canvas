//
//  TestDocumentControllerDelegate.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/23/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import CanvasNative

typealias Message = (BlockNode, Int)

final class TestDocumentControllerDelegate: DocumentControllerDelegate {

	// MARK: - Properties

	var blocks = [BlockNode]()
	var storage: NSMutableString = ""

	var presentationString: String {
		return storage as String
	}

	var willUpdate: (() -> Void)?
	var didInsert: ((BlockNode, Int) -> Void)?
	var didRemove: ((BlockNode, Int) -> Void)?
	var didUpdate: (() -> Void)?

	var blockTypes: [String] {
		return blocks.map { String(describing: $0) }
	}

	var blockDictionaries: [[String: Any]] {
		// Note that we're checking what the delegate thinks the blocks are. This makes sure all of the delegate
		// messages fire in the right order. If they didn't, this would be wrong and the test would fail. Yay.
		return blocks.map { $0.dictionary }
	}


	// MARK: - ControllerDelegate

	func documentControllerWillUpdateDocument(_ controller: DocumentController) {
		willUpdate?()
	}

	func documentController(_ controller: DocumentController, didReplaceCharactersInPresentationStringInRange range: NSRange, withString string: String) {
		storage.replaceCharacters(in: range, with: string)
	}

	func documentController(_ controller: DocumentController, didInsertBlock block: BlockNode, atIndex index: Int) {
		blocks.insert(block, at: index)
		didInsert?(block, index)
	}

	func documentController(_ controller: DocumentController, didRemoveBlock block: BlockNode, atIndex index: Int) {
		blocks.remove(at: index)
		didRemove?(block, index)
	}

	func documentControllerDidUpdateDocument(_ controller: DocumentController) {
		didUpdate?()
	}
}
