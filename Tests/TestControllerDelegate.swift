//
//  TestControllerDelegate.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/23/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasNative

final class TestControllerDelegate: ControllerDelegate {

	// MARK: - Properties

	var blocks = [BlockNode]()

	var willUpdate: (Void -> Void)?
	var didInsert: ((BlockNode, UInt) -> Void)?
	var didRemove: ((BlockNode, UInt) -> Void)?
	var didReplaceContent: ((BlockNode, UInt, BlockNode) -> Void)?
	var didUpdateLocation: ((BlockNode, UInt, BlockNode) -> Void)?
	var didUpdate: (Void -> Void)?


	// MARK: - ControllerDelegate

	func controllerWillUpdateNodes(controller: Controller) {
		willUpdate?()
	}

	func controller(controller: Controller, didInsertBlock block: BlockNode, atIndex index: UInt) {
		blocks.insert(block, atIndex: Int(index))
		didInsert?(block, index)
	}

	func controller(controller: Controller, didRemoveBlock block: BlockNode, atIndex index: UInt) {
		blocks.removeAtIndex(Int(index))
		didRemove?(block, index)
	}

	func controller(controller: Controller, didReplaceContentForBlock before: BlockNode, atIndex index: UInt, withBlock after: BlockNode) {
		blocks.removeAtIndex(Int(index))
		blocks.insert(after, atIndex: Int(index))
		didReplaceContent?(before, index, after)
	}

	func controller(controller: Controller, didUpdateLocationForBlock before: BlockNode, atIndex index: UInt, withBlock after: BlockNode) {
		blocks.removeAtIndex(Int(index))
		blocks.insert(after, atIndex: Int(index))
		didUpdateLocation?(before, index, after)
	}

	func controllerDidUpdateNodes(controller: Controller) {
		didUpdate?()
	}
}
