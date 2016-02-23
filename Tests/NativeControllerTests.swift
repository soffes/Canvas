//
//  NativeControllerTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/23/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
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


class NativeControllerTests: XCTestCase {

	let controller = NativeController()
	let delegate = ControllerDelegate()

	override func setUp() {
		super.setUp()
		controller.delegate = delegate
	}

	func testInsertingWithBlank() {
		// Will update
		let will = expectationWithDescription("nativeControllerWillUpdateNodes")
		delegate.willUpdateNodes = { will.fulfill() }

		// Insert
		let insertTitle = expectationWithDescription("nativeController:didInsertBlock:atIndex: Title")
		let insertParagraph = expectationWithDescription("nativeController:didInsertBlock:atIndex: Paragraph")
		delegate.didInsertBlockAtIndex = { node, index in
			if node is Title {
				XCTAssertEqual(0, index)
				insertTitle.fulfill()
			} else if node is Paragraph {
				XCTAssertEqual(1, index)
				insertParagraph.fulfill()
			} else {
				XCTFail("Unexpected insert.")
			}
		}

		// Did update
		let did = expectationWithDescription("nativeControllerDidUpdateNodes")
		delegate.didUpdateNodes = { did.fulfill() }

		// Edit characters
		controller.replaceCharactersInRange(NSRange(location: 0, length: 0), withString: "⧙doc-heading⧘Title\nParagraph")

		// Wait for expectations
		waitForExpectationsWithTimeout(0.5, handler: nil)
	}
}
