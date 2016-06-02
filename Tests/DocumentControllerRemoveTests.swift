//
//  DocumentControllerRemoveTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 3/9/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

class DocumentControllerRemoveTests: XCTestCase {

	// MARK: - Properties

	let delegate = TestDocumentControllerDelegate()


	// MARK: - Tests

	func testJoinBlock() {
		let controller = DocumentController(backingString: "⧙doc-heading⧘Title\nOne\nTwo", delegate: delegate)
		controller.replaceCharactersInRange(NSRange(location: 22, length: 1), withString: "")

		XCTAssertEqual(delegate.presentationString, controller.document.presentationString)
		XCTAssertEqual(blockTypes(controller.document.backingString), delegate.blockTypes)
	}

	func testMultipleJoin() {
		let controller = DocumentController(backingString: "⧙doc-heading⧘Title\nOne\nTwo\nThree", delegate: delegate)
		controller.replaceCharactersInRange(NSRange(location: 22, length: 5), withString: "")

		XCTAssertEqual(delegate.presentationString, controller.document.presentationString)
		XCTAssertEqual(blockTypes(controller.document.backingString), delegate.blockTypes)
	}

	func testMultipleRemoveBlock() {
		var delegate = TestDocumentControllerDelegate()
		var controller = DocumentController(backingString: "⧙doc-heading⧘Title\nOne\nTwo\nThree\nFour", delegate: delegate)
		controller.replaceCharactersInRange(NSRange(location: 22, length: 10), withString: "")
		XCTAssertEqual(delegate.presentationString, controller.document.presentationString)
		XCTAssertEqual(blockTypes(controller.document.backingString), delegate.blockTypes)

		delegate = TestDocumentControllerDelegate()
		controller = DocumentController(backingString: "⧙doc-heading⧘Title\nOne\nTwo\nThree\nFour", delegate: delegate)
		controller.replaceCharactersInRange(NSRange(location: 23, length: 10), withString: "")
		XCTAssertEqual(delegate.presentationString, controller.document.presentationString)
		XCTAssertEqual(blockTypes(controller.document.backingString), delegate.blockTypes)
	}
}
