//
//  NativeControllerDelegate.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/23/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasNative

final class ControllerDelegate: NativeControllerDelegate {

	// MARK: - Properties

	var willUpdateNodes: (Void -> Void)?
	var didInsertBlockAtIndex: ((BlockNode, UInt) -> Void)?
	var didRemoveBlockAtIndex: ((BlockNode, UInt) -> Void)?
	var didReplaceContentForBlockAtIndexWithBlock: ((BlockNode, UInt, BlockNode) -> Void)?
	var didUpdateLocationForBlockAtIndexWithBlock: ((BlockNode, UInt, BlockNode) -> Void)?
	var didUpdateNodes: (Void -> Void)?


	// MARK: - NativeControllerDelegate

	func nativeControllerWillUpdateNodes(nativeController: NativeController) {
		willUpdateNodes?()
	}

	func nativeController(nativeController: NativeController, didInsertBlock block: BlockNode, atIndex index: UInt) {
		didInsertBlockAtIndex?(block, index)
	}

	func nativeController(nativeController: NativeController, didRemoveBlock block: BlockNode, atIndex index: UInt) {
		didRemoveBlockAtIndex?(block, index)
	}

	func nativeController(nativeController: NativeController, didReplaceContentForBlock before: BlockNode, atIndex index: UInt, withBlock after: BlockNode) {
		didReplaceContentForBlockAtIndexWithBlock?(before, index, after)
	}

	func nativeController(nativeController: NativeController, didUpdateLocationForBlock before: BlockNode, atIndex index: UInt, withBlock after: BlockNode) {
		didUpdateLocationForBlockAtIndexWithBlock?(before, index, after)
	}

	func nativeControllerDidUpdateNodes(nativeController: NativeController) {
		didUpdateNodes?()
	}
}
