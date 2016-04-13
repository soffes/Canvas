//
//  DocumentControllerChangeTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/23/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

class DocumentControllerChangeTests: XCTestCase {

	// MARK: - Properties

	let delegate = TestDocumentControllerDelegate()


	// MARK: - Tests

	func testChange() {
		// Initial state
		let controller = DocumentController(backingString: "⧙doc-heading⧘Title\nOne\nTwo", delegate: delegate)

		let range = NSRange(location: 22, length: 0)
		let replacement = "!"

		// Will update
		let will = expectationWithDescription("willUpdate")
		delegate.willUpdate = { will.fulfill() }

		// Insert
		let insert = expectationWithDescription("didInsert")
		var inserted = false
		delegate.didInsert = { _, _ in
			if !inserted {
				insert.fulfill()
			}
			inserted = true
		}

		// Remove
		let remove = expectationWithDescription("didRemove")
		delegate.didRemove = { _, _ in
			remove.fulfill()
		}

		// Did update
		let did = expectationWithDescription("didUpdate")
		delegate.didUpdate = { did.fulfill() }

		// Edit characters
		controller.replaceCharactersInRange(range, withString: replacement)

		// Wait for expectations
		waitForExpectationsWithTimeout(0.5, handler: nil)

		// Check blocks
		XCTAssertEqual("⧙doc-heading⧘Title\nOne!\nTwo", controller.document.backingString)
		XCTAssertEqual(delegate.presentationString, controller.document.presentationString)
		XCTAssertEqual(blockTypes(controller.document.backingString), delegate.blockTypes)
	}

//	func testMultipleInsertRemove() {
//		// Initial state
//		controller.string = "⧙doc-heading⧘Title\nOne\nTwo\nThree\nFour"
//
//		let range = NSRange(location: 19, length: 18)
//		let replacement = "Hello\nWorld"
//		let blockRange = controller.blockRangeForCharacterRange(range, string: replacement)
//		XCTAssertEqual(NSRange(location: 1, length: 4), blockRange)
//
//		// Edit characters
//		controller.replaceCharactersInRange(range, withString: replacement)
//
//		// Check blocks
//		XCTAssertEqual("⧙doc-heading⧘Title\nHello\nWorld", controller.string)
//		XCTAssertEqual("Title\nHello\nWorld", delegate.presentationString)
//		XCTAssertEqual(parse(controller.string), delegate.blockDictionaries)
//	}

//	func testConvertToChecklist() {
//		controller.string = "⧙doc-heading⧘Title\n⧙unordered-list-0⧘- [ ]Hi"
//
//		controller.replaceCharactersInRange(NSRange(location: 20, length: 0), withString: "checklist-0⧘- [ ] ")
//		controller.replaceCharactersInRange(NSRange(location: 38, length: 22), withString: "")
//		XCTAssertEqual("⧙doc-heading⧘Title\n⧙checklist-0⧘- [ ] Hi", controller.string)
//	}

//	func testCheckChecklist() {
//		controller.string = "⧙doc-heading⧘Title\n⧙checklist-0⧘- [ ] Hi"
//		XCTAssertEqual("Title\nHi", delegate.presentationString)
//
//		controller.replaceCharactersInRange(NSRange(location: 35, length: 0), withString: "x")
//		controller.replaceCharactersInRange(NSRange(location: 36, length: 1), withString: "")
//
//		XCTAssertEqual("Title\nHi", delegate.presentationString)
//		XCTAssertEqual(parse(controller.string), delegate.blockDictionaries)
//	}
}
