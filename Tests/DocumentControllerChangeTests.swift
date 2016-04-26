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
		let controller = DocumentController(backingString: "⧙doc-heading⧘Title\nOne\nTwo", delegate: delegate)

		let will = expectationWithDescription("willUpdate")
		delegate.willUpdate = { will.fulfill() }

		var inserted = [Message]()
		delegate.didInsert = { block, index in
			print("Insert \(block.dynamicType) at \(index)")
			inserted.append((block, index))
		}

		var removed = [Message]()
		delegate.didRemove = { block, index in
			print("Remove \(block.dynamicType) at \(index)")
			removed.append((block, index))
		}

		let did = expectationWithDescription("didUpdate")
		delegate.didUpdate = { did.fulfill() }

		controller.replaceCharactersInRange(NSRange(location: 22, length: 0), withString: "!")
		waitForExpectationsWithTimeout(0.5, handler: nil)

		XCTAssertEqual(2, inserted.count)
		XCTAssertEqual(2, removed.count)

		XCTAssertEqual(delegate.presentationString, controller.document.presentationString)
		XCTAssertEqual(blockTypes(controller.document.backingString), delegate.blockTypes)
	}

	func testMultipleInsertRemove() {
		let controller = DocumentController(backingString: "⧙doc-heading⧘Title\nOne\nTwo\nThree\nFour", delegate: delegate)
		controller.replaceCharactersInRange(NSRange(location: 19, length: 18), withString: "Hello\nWorld")

		XCTAssertEqual(delegate.presentationString, controller.document.presentationString)
		XCTAssertEqual(blockTypes(controller.document.backingString), delegate.blockTypes)
	}

	func testConvertToChecklist() {
		let controller = DocumentController(backingString: "⧙doc-heading⧘Title\n⧙unordered-list-0⧘- [ ]Hi", delegate: delegate)
		controller.replaceCharactersInRange(NSRange(location: 20, length: 0), withString: "checklist-0⧘- [ ] ")
		controller.replaceCharactersInRange(NSRange(location: 38, length: 22), withString: "")

		XCTAssertEqual(delegate.presentationString, controller.document.presentationString)
		XCTAssertEqual(blockTypes(controller.document.backingString), delegate.blockTypes)
	}

	func testCheckChecklist() {
		let controller = DocumentController(backingString: "⧙doc-heading⧘Title\n⧙checklist-0⧘- [ ] Hi", delegate: delegate)
		controller.replaceCharactersInRange(NSRange(location: 35, length: 0), withString: "x")
		controller.replaceCharactersInRange(NSRange(location: 36, length: 1), withString: "")

		XCTAssertEqual(delegate.presentationString, controller.document.presentationString)
		XCTAssertEqual(blockTypes(controller.document.backingString), delegate.blockTypes)
	}
}
