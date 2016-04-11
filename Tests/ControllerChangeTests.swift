//
//  ControllerChangeTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/23/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
@testable import CanvasNative

class ControllerChangeTests: XCTestCase {

	// MARK: - Properties

	let controller = Controller()
	let delegate = TestControllerDelegate()


	// MARK: - XCTestCase

	override func setUp() {
		super.setUp()
		controller.delegate = delegate
	}


	// MARK: - Tests

	func testChange() {
		// Initial state
		controller.string = "⧙doc-heading⧘Title\nOne\nTwo"

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
		XCTAssertEqual("Title\nOne!\nTwo", delegate.presentationString)
		XCTAssertEqual(parse(controller.string), delegate.blockDictionaries)
	}

	func testMultipleInsertRemove() {
		// Initial state
		controller.string = "⧙doc-heading⧘Title\nOne\nTwo\nThree\nFour"

		let range = NSRange(location: 19, length: 18)
		let replacement = "Hello\nWorld"
		let blockRange = controller.blockRangeForCharacterRange(range, string: replacement)
		XCTAssertEqual(NSRange(location: 1, length: 4), blockRange)

		// Edit characters
		controller.replaceCharactersInRange(range, withString: replacement)

		// Check blocks
		XCTAssertEqual("⧙doc-heading⧘Title\nHello\nWorld", controller.string)
		XCTAssertEqual("Title\nHello\nWorld", delegate.presentationString)
		XCTAssertEqual(parse(controller.string), delegate.blockDictionaries)
	}

	func testConvertToChecklist() {
		controller.string = "⧙doc-heading⧘Title\n⧙unordered-list-0⧘- [ ]Hi"

		controller.replaceCharactersInRange(NSRange(location: 20, length: 0), withString: "checklist-0⧘- [ ] ")
//		controller.replaceCharactersInRange(NSRange(location: 38, length: 22), withString: "")
		XCTAssertEqual("⧙doc-heading⧘Title\n⧙checklist-0⧘- [ ] Hi", controller.string)
	}

	func testCheckChecklist() {
//		controller.string = "⧙doc-heading⧘Title\n⧙checklist-0⧘- [ ] Hi"
//		XCTAssertEqual("Title\nHi", delegate.presentationString)
//
//		controller.replaceCharactersInRange(NSRange(location: 35, length: 0), withString: "x")
//		controller.replaceCharactersInRange(NSRange(location: 36, length: 1), withString: "")
//
//		XCTAssertEqual("Title\nHi", delegate.presentationString)
//		XCTAssertEqual(parse(controller.string), delegate.blockDictionaries)
		XCTFail("Pending")
	}
}
