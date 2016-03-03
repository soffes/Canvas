//
//  TestCanvasControllerDelegate.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/23/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import CanvasNative

final class TestCanvasControllerDelegate: CanvasControllerDelegate {

	// MARK: - Properties

	var blocks = [BlockNode]()
	var presentationString: NSMutableString = ""

	var willUpdate: (Void -> Void)?
	var didInsert: ((BlockNode, Int) -> Void)?
	var didRemove: ((BlockNode, Int) -> Void)?
	var didReplaceContent: ((BlockNode, Int, BlockNode) -> Void)?
	var didUpdateLocation: ((BlockNode, Int, BlockNode) -> Void)?
	var didUpdate: (Void -> Void)?


	// MARK: - CanvasControllerDelegate

	func canvasControllerWillUpdateNodes(canvasController: CanvasController) {
		willUpdate?()
	}

	func canvasController(canvasController: CanvasController, didInsertBlock block: BlockNode, atIndex index: Int) {
		blocks.insert(block, atIndex: index)
		didInsert?(block, index)
	}

	func canvasController(canvasController: CanvasController, didRemoveBlock block: BlockNode, atIndex index: Int) {
		blocks.removeAtIndex(index)
		didRemove?(block, index)
	}

	func canvasController(canvasController: CanvasController, didReplaceContentForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode) {
		blocks.removeAtIndex(index)
		blocks.insert(after, atIndex: index)
		didReplaceContent?(before, index, after)
	}

	func canvasController(canvasController: CanvasController, didUpdateLocationForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode) {
		blocks.removeAtIndex(index)
		blocks.insert(after, atIndex: index)
		didUpdateLocation?(before, index, after)
	}

	func canvasControllerDidUpdateNodes(canvasController: CanvasController) {
		didUpdate?()
	}

	func canvasController(canvasController: CanvasController, didReplaceCharactersInPresentationStringInRange range: NSRange, withString string: String) {
		presentationString.replaceCharactersInRange(range, withString: string)
	}
}
