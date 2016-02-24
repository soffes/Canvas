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

	// MARK: - Properties

	private let controller = NativeController()

	private let delegate = ControllerDelegate()

	private var blockTypes: [String] {
		return controller.blocks.map { String($0.dynamicType) }
	}


	// MARK: - XCTestCase

	override func setUp() {
		super.setUp()
		controller.delegate = delegate
	}


	// MARK: - Tests

	func testLoading() {
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

		// Ignored
		delegate.didRemoveBlockAtIndex = { _, _ in XCTFail("Shouldn't remove.") }
		delegate.didReplaceContentForBlockAtIndexWithBlock = { _, _, _ in XCTFail("Shouldn't replace.") }
		delegate.didUpdateLocationForBlockAtIndexWithBlock = { _, _, _ in XCTFail("Shouldn't update.") }

		// Did update
		let did = expectationWithDescription("nativeControllerDidUpdateNodes")
		delegate.didUpdateNodes = { did.fulfill() }

		// Edit characters
		controller.replaceCharactersInRange(NSRange(location: 0, length: 0), withString: "⧙doc-heading⧘Title\nParagraph")

		// Wait for expectations
		waitForExpectationsWithTimeout(0.5, handler: nil)

		// Check blocks
		XCTAssertEqual(["Title", "Paragraph"], blockTypes)
	}

	func testChange() {
		// Initial state
		controller.replaceCharactersInRange(NSRange(location: 0, length: 0), withString: "⧙doc-heading⧘Title\nOne\nTwo")
		let beforeParagraph1 = controller.blocks[1]
		let beforeParagraph2 = controller.blocks[2]

		// Will update
		let will = expectationWithDescription("nativeControllerWillUpdateNodes")
		delegate.willUpdateNodes = { will.fulfill() }

		// Replace
		let replace = expectationWithDescription("nativeController:didReplaceContentForBlock:atIndex:withBlock:")
		delegate.didReplaceContentForBlockAtIndexWithBlock = { before, index, after in
			XCTAssertEqual("Paragraph", String(before.dynamicType))
			XCTAssertEqual(beforeParagraph1.range, before.range)
			XCTAssertEqual(1, index)
			XCTAssertEqual("Paragraph", String(after.dynamicType))
			XCTAssertEqual(NSRange(location: 19, length: 4), after.range)

			replace.fulfill()
		}

		// Update
		let update = expectationWithDescription("nativeController:didUpdateLocationForBlock:atIndex:withBlock:")
		delegate.didUpdateLocationForBlockAtIndexWithBlock = { before, index, after in
			XCTAssertEqual("Paragraph", String(before.dynamicType))
			XCTAssertEqual(beforeParagraph2.range, before.range)
			XCTAssertEqual(2, index)
			XCTAssertEqual("Paragraph", String(after.dynamicType))
			XCTAssertEqual(NSRange(location: 24, length: 3), after.range)

			update.fulfill()
		}

		// Ignored
		delegate.didInsertBlockAtIndex = { _, _ in XCTFail("Shouldn't insert.") }
		delegate.didRemoveBlockAtIndex = { _, _ in XCTFail("Shouldn't remove.") }

		// Did update
		let did = expectationWithDescription("nativeControllerDidUpdateNodes")
		delegate.didUpdateNodes = { did.fulfill() }

		// Edit characters
		controller.replaceCharactersInRange(NSRange(location: 22, length: 0), withString: "!")

		// Wait for expectations
		waitForExpectationsWithTimeout(0.5, handler: nil)

		// Check blocks
		XCTAssertEqual(["Title", "Paragraph", "Paragraph"], blockTypes)
	}

	func testInsert() {
		// Initial state
		controller.replaceCharactersInRange(NSRange(location: 0, length: 0), withString: "⧙doc-heading⧘Title\nOne\n⧙blockquote⧘> Two")
		let blockquote = controller.blocks[2]

		// Will update
		let will = expectationWithDescription("nativeControllerWillUpdateNodes")
		delegate.willUpdateNodes = { will.fulfill() }

		// Insert
		let insert = expectationWithDescription("nativeController:didInsertBlock:atIndex:")
		delegate.didInsertBlockAtIndex = { block, index in
			XCTAssertEqual("CodeBlock", String(block.dynamicType))
			XCTAssertEqual(NSRange(location: 23, length: 10), block.range)
			XCTAssertEqual(2, index)

			insert.fulfill()
		}

		// Update
		let update = expectationWithDescription("nativeController:didUpdateLocationForBlock:atIndex:withBlock:")
		delegate.didUpdateLocationForBlockAtIndexWithBlock = { before, index, after in
			XCTAssertEqual("Blockquote", String(before.dynamicType))
			XCTAssertEqual(blockquote.range, before.range)
			XCTAssertEqual(3, index)
			XCTAssertEqual("Blockquote", String(after.dynamicType))
			XCTAssertEqual(NSRange(location: 34, length: 17), after.range)

			update.fulfill()
		}

		// Ignored
		delegate.didRemoveBlockAtIndex = { _, _ in XCTFail("Shouldn't remove.") }

		// Did update
		let did = expectationWithDescription("nativeControllerDidUpdateNodes")
		delegate.didUpdateNodes = { did.fulfill() }

		// Edit characters
		controller.replaceCharactersInRange(NSRange(location: 22, length: 0), withString: "\n⧙code⧘Half")

		// Wait for expectations
		waitForExpectationsWithTimeout(0.5, handler: nil)

		// Check blocks
		XCTAssertEqual(["Title", "Paragraph", "CodeBlock", "Blockquote"], blockTypes)
	}

	func testRemove() {
		// Initial state
		controller.replaceCharactersInRange(NSRange(location: 0, length: 0), withString: "⧙doc-heading⧘Title\nOne\n⧙blockquote⧘> Two")
		let blockquote = controller.blocks[2]

		// Will update
		let will = expectationWithDescription("nativeControllerWillUpdateNodes")
		delegate.willUpdateNodes = { will.fulfill() }

		// Remove
		let remove = expectationWithDescription("nativeController:didRemoveBlock:atIndex:")
		delegate.didRemoveBlockAtIndex = { block, index in
			XCTAssertEqual("Paragraph", String(block.dynamicType))
			XCTAssertEqual(1, index)
			remove.fulfill()
		}

		// Insert
		delegate.didInsertBlockAtIndex = { _, _ in XCTFail("Shouldn't insert.") }

		// Update
		let update = expectationWithDescription("nativeController:didUpdateLocationForBlock:atIndex:withBlock:")
		delegate.didUpdateLocationForBlockAtIndexWithBlock = { before, index, after in
			XCTAssertEqual("Blockquote", String(before.dynamicType))
			XCTAssertEqual(blockquote.range, before.range)
			XCTAssertEqual(1, index)
			XCTAssertEqual("Blockquote", String(after.dynamicType))
			XCTAssertEqual(NSRange(location: 19, length: 17), after.range)

			update.fulfill()
		}

		// Did update
		let did = expectationWithDescription("nativeControllerDidUpdateNodes")
		delegate.didUpdateNodes = { did.fulfill() }

		// Edit characters
		controller.replaceCharactersInRange(NSRange(location: 19, length: 4), withString: "")

		// Wait for expectations
		waitForExpectationsWithTimeout(0.5, handler: nil)

		// Check blocks
		XCTAssertEqual(["Title", "Blockquote"], blockTypes)
	}
}
