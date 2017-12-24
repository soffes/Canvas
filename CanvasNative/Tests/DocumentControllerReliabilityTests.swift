//
//  DocumentControllerReliabilityTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 3/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

final class DocumentControllerReliabilityTests: XCTestCase {

	// MARK: - Properties

	let delegate = TestDocumentControllerDelegate()


	// MARK: - Tests

	func testReliabilityInsertMidParagraph() {
		let controller = DocumentController(backingString: "⧙doc-heading⧘Title\nOne\nTwo", delegate: delegate)
		controller.replaceCharactersInRange(NSRange(location: 21, length: 0), withString: "1")
		XCTAssertEqual(delegate.presentationString, controller.document.presentationString)
		XCTAssertEqual(blockTypes(controller.document.backingString), delegate.blockTypes)

		controller.replaceCharactersInRange(NSRange(location: 22, length: 0), withString: "2")
		XCTAssertEqual(delegate.presentationString, controller.document.presentationString)
		XCTAssertEqual(blockTypes(controller.document.backingString), delegate.blockTypes)
	}
}
