//
//  ControllerDelegate.swift
//  CanvasNative
//
//  Created by Sam Soffes on 3/11/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

public protocol ControllerDelegate: class {
	// After this message, `blocks` will be the new value
	func controllerWillUpdateNodes(controller: Controller)

	// This will be called before all other messages.
	func controller(controller: Controller, didReplaceCharactersInPresentationStringInRange range: NSRange, withString string: String)

	// The index will be relative to the blocks array before the change (similar to UITableView).
	func controller(controller: Controller, didInsertBlock block: BlockNode, atIndex index: Int)

	func controller(controller: Controller, didRemoveBlock block: BlockNode, atIndex index: Int)

	// The block's content changed. `before` and `after` will always be the same type.
	func controller(controller: Controller, didReplaceContentForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode)

	// The block's metadata changed. `before` and `after` will always be the same type.
	func controller(controller: Controller, didUpdateLocationForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode)

	func controllerDidUpdateNodes(controller: Controller)
}
