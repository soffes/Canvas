//
//  NativeControllerTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/23/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

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
		XCTAssertEqual("⧙doc-heading⧘Title\nParagraph", controller.string)
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
		XCTAssertEqual("⧙doc-heading⧘Title\nOne!\nTwo", controller.string)
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
		delegate.didReplaceContentForBlockAtIndexWithBlock = { _, _, _ in XCTFail("Shouldn't reokace.") }
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
		XCTAssertEqual("⧙doc-heading⧘Title\nOne\n⧙code⧘Half\n⧙blockquote⧘> Two", controller.string)
	}

	func testSplit() {
		// Initial state
		controller.replaceCharactersInRange(NSRange(location: 0, length: 0), withString: "⧙doc-heading⧘Title\nOne\n⧙blockquote⧘> Two")
		let blockquote = controller.blocks[2]

		// Will update
		let will = expectationWithDescription("nativeControllerWillUpdateNodes")
		delegate.willUpdateNodes = { will.fulfill() }

		// Insert
		let insert = expectationWithDescription("nativeController:didInsertBlock:atIndex:")
		delegate.didInsertBlockAtIndex = { block, index in
			// TODO: Remove this
			guard block is CodeBlock else { return }
			
			XCTAssertEqual("CodeBlock", String(block.dynamicType))
			XCTAssertEqual(NSRange(location: 22, length: 8), block.range)
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
			XCTAssertEqual(NSRange(location: 31, length: 17), after.range)

			update.fulfill()
		}

		// Ignored
		delegate.didRemoveBlockAtIndex = { _, _ in XCTFail("Shouldn't remove.") }

		// Did update
		let did = expectationWithDescription("nativeControllerDidUpdateNodes")
		delegate.didUpdateNodes = { did.fulfill() }

		// Edit characters
		controller.replaceCharactersInRange(NSRange(location: 21, length: 0), withString: "\n⧙code⧘T")

		// Wait for expectations
		waitForExpectationsWithTimeout(0.5, handler: nil)

		// Check blocks
		XCTAssertEqual(["Title", "Paragraph", "CodeBlock", "Blockquote"], blockTypes)
		XCTAssertEqual("⧙doc-heading⧘Title\nOn\n⧙code⧘Te\n⧙blockquote⧘> Two", controller.string)
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

		// Ignored
		delegate.didInsertBlockAtIndex = { _, _ in XCTFail("Shouldn't insert.") }
		delegate.didReplaceContentForBlockAtIndexWithBlock = { _, _, _ in XCTFail("Shouldn't reokace.") }

		// Edit characters
		controller.replaceCharactersInRange(NSRange(location: 19, length: 4), withString: "")

		// Wait for expectations
		waitForExpectationsWithTimeout(0.5, handler: nil)

		// Check blocks
		XCTAssertEqual(["Title", "Blockquote"], blockTypes)
		XCTAssertEqual("⧙doc-heading⧘Title\n⧙blockquote⧘> Two", controller.string)
	}
}
