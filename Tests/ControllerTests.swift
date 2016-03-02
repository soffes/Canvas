//
//  ControllerTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/23/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
@testable import CanvasNative

class ControllerTests: XCTestCase {

	// MARK: - Properties

	private let controller = Controller()

	private let delegate = TestControllerDelegate()

	private var blockDictionaries: [[String: AnyObject]] {
		// Note that we're checking what the delegate thinks the blocks are. This makes sure all of the delegate
		// messages fire in the right order. If they didn't, this would be wrong and the test would fail. Yay.
		return delegate.blocks.map { $0.dictionary }
	}


	// MARK: - XCTestCase

	override func setUp() {
		super.setUp()
		controller.delegate = delegate
	}


	// MARK: - Tests

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
		controller.replaceCharactersInRange(.zero, withString: "⧙doc-heading⧘Title\nParagraph")

		// Wait for expectations
		waitForExpectationsWithTimeout(0.5, handler: nil)

		// Check blocks
		XCTAssertEqual("⧙doc-heading⧘Title\nParagraph", controller.string)
		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}

	func testChange() {
		// Initial state
		controller.replaceCharactersInRange(.zero, withString: "⧙doc-heading⧘Title\nOne\nTwo")

		let range = NSRange(location: 22, length: 0)
		let replacement = "!"
		let blockRange = controller.blockRangeForCharacterRange(range, string: replacement)
		XCTAssertEqual(NSRange(location: 1, length: 1), blockRange)

		let beforeParagraph1 = controller.blocks[1]
		let beforeParagraph2 = controller.blocks[2]

		// Will update
		let will = expectationWithDescription("controllerWillUpdateNodes")
		delegate.willUpdate = { will.fulfill() }

		// Replace
		let replace = expectationWithDescription("controller:didReplaceContentForBlock:atIndex:withBlock:")
		delegate.didReplaceContent = { before, index, after in
			XCTAssertEqual("Paragraph", String(before.dynamicType))
			XCTAssertEqual(beforeParagraph1.range, before.range)
			XCTAssertEqual(1, index)
			XCTAssertEqual("Paragraph", String(after.dynamicType))
			XCTAssertEqual(NSRange(location: 19, length: 4), after.range)

			replace.fulfill()
		}

		// Update
		let update = expectationWithDescription("controller:didUpdateLocationForBlock:atIndex:withBlock:")
		delegate.didUpdateLocation = { before, index, after in
			XCTAssertEqual("Paragraph", String(before.dynamicType))
			XCTAssertEqual(beforeParagraph2.range, before.range)
			XCTAssertEqual(2, index)
			XCTAssertEqual("Paragraph", String(after.dynamicType))
			XCTAssertEqual(NSRange(location: 24, length: 3), after.range)

			update.fulfill()
		}

		// Ignored
		delegate.didInsert = { _, _ in XCTFail("Shouldn't insert.") }
		delegate.didRemove = { _, _ in XCTFail("Shouldn't remove.") }

		// Did update
		let did = expectationWithDescription("controllerDidUpdateNodes")
		delegate.didUpdate = { did.fulfill() }

		// Edit characters
		controller.replaceCharactersInRange(range, withString: replacement)

		// Wait for expectations
		waitForExpectationsWithTimeout(0.5, handler: nil)

		// Check blocks
		XCTAssertEqual("⧙doc-heading⧘Title\nOne!\nTwo", controller.string)
		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}

	func testInsert() {
		// Initial state
		controller.replaceCharactersInRange(.zero, withString: "⧙doc-heading⧘Title\nOne\n⧙blockquote⧘> Two")
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
		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}

	func testRemove() {
		// Initial state
		controller.replaceCharactersInRange(.zero, withString: "⧙doc-heading⧘Title\nOne\n⧙blockquote⧘> Two")
		let blockquote = controller.blocks[2]

		// Will update
		let will = expectationWithDescription("controllerWillUpdateNodes")
		delegate.willUpdate = { will.fulfill() }

		// Remove
		let remove = expectationWithDescription("controller:didRemoveBlock:atIndex:")
		delegate.didRemove = { block, index in
			XCTAssertEqual("Paragraph", String(block.dynamicType))
			XCTAssertEqual(1, index)
			remove.fulfill()
		}

		// Update
		let update = expectationWithDescription("controller:didUpdateLocationForBlock:atIndex:withBlock:")
		delegate.didUpdateLocation = { before, index, after in
			XCTAssertEqual("Blockquote", String(before.dynamicType))
			XCTAssertEqual(blockquote.range, before.range)
			XCTAssertEqual(1, index)
			XCTAssertEqual("Blockquote", String(after.dynamicType))
			XCTAssertEqual(NSRange(location: 19, length: 17), after.range)

			update.fulfill()
		}

		// Did update
		let did = expectationWithDescription("controllerDidUpdateNodes")
		delegate.didUpdate = { did.fulfill() }

		// Ignored
		delegate.didInsert = { _, _ in XCTFail("Shouldn't insert.") }
		delegate.didReplaceContent = { _, _, _ in XCTFail("Shouldn't replace.") }

		// Edit characters
		controller.replaceCharactersInRange(NSRange(location: 19, length: 4), withString: "")

		// Wait for expectations
		waitForExpectationsWithTimeout(0.5, handler: nil)

		// Check blocks
		XCTAssertEqual("⧙doc-heading⧘Title\n⧙blockquote⧘> Two", controller.string)
		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}

	func testSplit() {
		// Initial state
		controller.replaceCharactersInRange(.zero, withString: "⧙doc-heading⧘Title\nOne\n⧙blockquote⧘> Two")

		// Edit characters
		controller.replaceCharactersInRange(NSRange(location: 21, length: 0), withString: "\n⧙code⧘T")

		// Check blocks
		XCTAssertEqual("⧙doc-heading⧘Title\nOn\n⧙code⧘Te\n⧙blockquote⧘> Two", controller.string)
		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}

	func testJoin() {
		// Initial state
		controller.replaceCharactersInRange(.zero, withString: "⧙doc-heading⧘Title\nOne\nTwo")

		let range = NSRange(location: 22, length: 1)
		let replacement = ""
		let blockRange = controller.blockRangeForCharacterRange(range, string: replacement)
		XCTAssertEqual(NSRange(location: 1, length: 2), blockRange)

		// Edit characters
		controller.replaceCharactersInRange(range, withString: replacement)

		// Check blocks
		XCTAssertEqual("⧙doc-heading⧘Title\nOneTwo", controller.string)
		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}

	func testMultipleInsert() {
		// Initial state
		controller.replaceCharactersInRange(.zero, withString: "⧙doc-heading⧘Title\nOne")

		let range = NSRange(location: 22, length: 0)
		let replacement = "\nHello\nWorld"
		let blockRange = controller.blockRangeForCharacterRange(range, string: replacement)
		XCTAssertEqual(NSRange(location: 2, length: 0), blockRange)

		// Edit characters
		controller.replaceCharactersInRange(range, withString: replacement)

		// Check blocks
		XCTAssertEqual("⧙doc-heading⧘Title\nOne\nHello\nWorld", controller.string)
		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}

	func testMultipleRemove() {
		// Initial state
		controller.replaceCharactersInRange(.zero, withString: "⧙doc-heading⧘Title\nOne\nTwo\nThree\nFour")

		let range = NSRange(location: 22, length: 10)
		let replacement = ""
		let blockRange = controller.blockRangeForCharacterRange(range, string: replacement)
		XCTAssertEqual(NSRange(location: 2, length: 2), blockRange)

		// Edit characters
		controller.replaceCharactersInRange(range, withString: replacement)

		// Check blocks
		XCTAssertEqual("⧙doc-heading⧘Title\nOne\nFour", controller.string)
		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}

	func testMultipleInsertRemove() {
		// Initial state
		controller.replaceCharactersInRange(.zero, withString: "⧙doc-heading⧘Title\nOne\nTwo\nThree\nFour")

		let range = NSRange(location: 19, length: 18)
		let replacement = "Hello\nWorld"
		let blockRange = controller.blockRangeForCharacterRange(range, string: replacement)
		XCTAssertEqual(NSRange(location: 1, length: 4), blockRange)

		// Edit characters
		controller.replaceCharactersInRange(range, withString: replacement)

		// Check blocks
		XCTAssertEqual("⧙doc-heading⧘Title\nHello\nWorld", controller.string)
		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}


	// MARK: - Private

	private func parse(string: String) -> [[String: AnyObject]] {
		return Parser.parse(string).map { $0.dictionary }
	}
}
