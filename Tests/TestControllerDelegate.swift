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

	var willUpdateNodes: (Void -> Void)?
	var didInsertBlockAtIndex: ((BlockNode, UInt) -> Void)?
	var didRemoveBlockAtIndex: ((BlockNode, UInt) -> Void)?
	var didReplaceContentForBlockAtIndexWithBlock: ((BlockNode, UInt, BlockNode) -> Void)?
	var didUpdateLocationForBlockAtIndexWithBlock: ((BlockNode, UInt, BlockNode) -> Void)?
	var didUpdateNodes: (Void -> Void)?


	// MARK: - ControllerDelegate

	func controllerWillUpdateNodes(controller: Controller) {
		willUpdateNodes?()
	}

	func controller(controller: Controller, didInsertBlock block: BlockNode, atIndex index: UInt) {
		didInsertBlockAtIndex?(block, index)
	}

	func controller(controller: Controller, didRemoveBlock block: BlockNode, atIndex index: UInt) {
		didRemoveBlockAtIndex?(block, index)
	}

	func controller(controller: Controller, didReplaceContentForBlock before: BlockNode, atIndex index: UInt, withBlock after: BlockNode) {
		didReplaceContentForBlockAtIndexWithBlock?(before, index, after)
	}

	func controller(controller: Controller, didUpdateLocationForBlock before: BlockNode, atIndex index: UInt, withBlock after: BlockNode) {
		didUpdateLocationForBlockAtIndexWithBlock?(before, index, after)
	}

	func controllerDidUpdateNodes(controller: Controller) {
		didUpdateNodes?()
	}
}
