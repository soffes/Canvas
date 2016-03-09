//
//  CanvasControllerTests+Insert.swift
//  CanvasNative
//
//  Created by Sam Soffes on 3/9/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
@testable import CanvasNative

extension CanvasControllerTests {
	func testLoading() {
		// Will update
		let will = expectationWithDescription("controllerWillUpdateNodes")
		delegate.willUpdate = { will.fulfill() }

		// Insert
		let insertTitle = expectationWithDescription("controller:didInsertBlock:atIndex: Title")
		let insertParagraph = expectationWithDescription("controller:didInsertBlock:atIndex: Paragraph")
		delegate.didInsert = { node, index in
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
		delegate.didRemove = { _, _ in XCTFail("Shouldn't remove.") }
		delegate.didReplaceContent = { _, _, _ in XCTFail("Shouldn't replace.") }
		delegate.didUpdateLocation = { _, _, _ in XCTFail("Shouldn't update.") }

		// Did update
		let did = expectationWithDescription("controllerDidUpdateNodes")
		delegate.didUpdate = { did.fulfill() }

		// Edit characters
		controller.string = "⧙doc-heading⧘Title\nParagraph"

		// Wait for expectations
		waitForExpectationsWithTimeout(0.5, handler: nil)

		// Check blocks
		XCTAssertEqual("⧙doc-heading⧘Title\nParagraph", controller.string)
		XCTAssertEqual("Title\nParagraph", delegate.presentationString)
		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}

	func testInsert() {
		// Initial state
		controller.string = "⧙doc-heading⧘Title\nOne\n⧙blockquote⧘> Two"
		let blockquote = controller.blocks[2]

		let range = NSRange(location: 22, length: 0)
		let replacement = "\n⧙code⧘Half"
		let blockRange = controller.blockRangeForCharacterRange(range, string: replacement)
		XCTAssertEqual(NSRange(location: 2, length: 0), blockRange)

		// Will update
		let will = expectationWithDescription("controllerWillUpdateNodes")
		delegate.willUpdate = { will.fulfill() }

		// Insert
		let insert = expectationWithDescription("controller:didInsertBlock:atIndex:")
		delegate.didInsert = { block, index in
			XCTAssertEqual("CodeBlock", String(block.dynamicType))
			XCTAssertEqual(NSRange(location: 23, length: 10), block.range)
			XCTAssertEqual(2, index)

			insert.fulfill()
		}

		// Update
		let update = expectationWithDescription("controller:didUpdateLocationForBlock:atIndex:withBlock:")
		delegate.didUpdateLocation = { before, index, after in
			XCTAssertEqual("Blockquote", String(before.dynamicType))
			XCTAssertEqual(blockquote.range, before.range)
			XCTAssertEqual(3, index)
			XCTAssertEqual("Blockquote", String(after.dynamicType))
			XCTAssertEqual(NSRange(location: 34, length: 17), after.range)

			update.fulfill()
		}

		// Ignored
		delegate.didReplaceContent = { _, _, _ in XCTFail("Shouldn't replace.") }
		delegate.didRemove = { _, _ in XCTFail("Shouldn't remove.") }

		// Did update
		let did = expectationWithDescription("controllerDidUpdateNodes")
		delegate.didUpdate = { did.fulfill() }

		// Edit characters
		controller.replaceCharactersInRange(range, withString: replacement)

		// Wait for expectations
		waitForExpectationsWithTimeout(0.5, handler: nil)

		// Check blocks
		XCTAssertEqual("⧙doc-heading⧘Title\nOne\n⧙code⧘Half\n⧙blockquote⧘> Two", controller.string)
		XCTAssertEqual("Title\nOne\nHalf\nTwo", delegate.presentationString)
		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}

	func testMultipleInsert() {
		// Initial state
		controller.string = "⧙doc-heading⧘Title\nOne"

		let range = NSRange(location: 22, length: 0)
		let replacement = "\nHello\nWorld"
		let blockRange = controller.blockRangeForCharacterRange(range, string: replacement)
		XCTAssertEqual(NSRange(location: 1, length: 1), blockRange)

		// Edit characters
		controller.replaceCharactersInRange(range, withString: replacement)

		// Check blocks
		XCTAssertEqual("⧙doc-heading⧘Title\nOne\nHello\nWorld", controller.string)
		XCTAssertEqual("Title\nOne\nHello\nWorld", delegate.presentationString)
		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}

	func testSplit() {
		controller.string = "⧙doc-heading⧘Title\nOne\n⧙blockquote⧘> Two"
		controller.replaceCharactersInRange(NSRange(location: 21, length: 0), withString: "\n⧙code⧘T")
		XCTAssertEqual("⧙doc-heading⧘Title\nOn\n⧙code⧘Te\n⧙blockquote⧘> Two", controller.string)
		XCTAssertEqual("Title\nOn\nTe\nTwo", delegate.presentationString)
		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}
}
