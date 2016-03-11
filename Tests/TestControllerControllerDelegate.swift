//
//  TestControllerDelegate.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/23/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import CanvasNative

final class TestControllerDelegate: ControllerDelegate {

	// MARK: - Properties

	var blocks = [BlockNode]()
	var presentationString: NSMutableString = ""

	var blockDictionaries: [[String: AnyObject]] {
		// Note that we're checking what the delegate thinks the blocks are. This makes sure all of the delegate
		// messages fire in the right order. If they didn't, this would be wrong and the test would fail. Yay.
		return blocks.map { $0.dictionary }
	}

	var willUpdate: (Void -> Void)?
	var didInsert: ((BlockNode, Int) -> Void)?
	var didRemove: ((BlockNode, Int) -> Void)?
	var didReplaceContent: ((BlockNode, Int, BlockNode) -> Void)?
	var didUpdateLocation: ((BlockNode, Int, BlockNode) -> Void)?
	var didUpdate: (Void -> Void)?


	// MARK: - ControllerDelegate

	func controllerWillUpdateNodes(controller: Controller) {
		willUpdate?()
	}

	func controller(controller: Controller, didInsertBlock block: BlockNode, atIndex index: Int) {
		blocks.insert(block, atIndex: index)
		didInsert?(block, index)
	}

	func controller(controller: Controller, didRemoveBlock block: BlockNode, atIndex index: Int) {
		blocks.removeAtIndex(index)
		didRemove?(block, index)
	}

	func controller(controller: Controller, didReplaceContentForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode) {
		blocks.removeAtIndex(index)
		blocks.insert(after, atIndex: index)
		didReplaceContent?(before, index, after)
	}

	func controller(controller: Controller, didUpdateLocationForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode) {
		blocks.removeAtIndex(index)
		blocks.insert(after, atIndex: index)
		didUpdateLocation?(before, index, after)
	}

	func controllerDidUpdateNodes(controller: Controller) {
		didUpdate?()
	}

	func controller(controller: Controller, didReplaceCharactersInPresentationStringInRange range: NSRange, withString string: String) {
		presentationString.replaceCharactersInRange(range, withString: string)
	}
}
