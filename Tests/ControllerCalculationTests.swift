//
//  ControllerCalculationTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 3/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
@testable import CanvasNative

class ControllerCalculationTests: XCTestCase {

	// MARK: - Properties

	let controller = Controller()
	let delegate = TestControllerDelegate()


	// MARK: - XCTestCase

	override func setUp() {
		super.setUp()
		controller.delegate = delegate
	}


	// MARK: - Tests

	func testBackingRangeToPresentationRange() {
		controller.string = "⧙doc-heading⧘Title\nOne\n⧙blockquote⧘> Two\n⧙code⧘Three"
		XCTAssertEqual("Title\nOne\nTwo\nThree", delegate.presentationString)

		XCTAssertEqual(NSRange(location: 0, length: 5), controller.presentationRange(backingRange: controller.blocks[0].visibleRange))
		XCTAssertEqual(NSRange(location: 6, length: 3), controller.presentationRange(backingRange: controller.blocks[1].visibleRange))
		XCTAssertEqual(NSRange(location: 10, length: 3), controller.presentationRange(backingRange: controller.blocks[2].visibleRange))
		XCTAssertEqual(NSRange(location: 14, length: 5), controller.presentationRange(backingRange: controller.blocks[3].visibleRange))
	}

	func testPresentationRangeToBackingRange() {
		controller.string = "⧙doc-heading⧘Title\nOne\n⧙blockquote⧘> Two\n⧙code⧘Three"
		XCTAssertEqual("Title\nOne\nTwo\nThree", delegate.presentationString)

		XCTAssertEqual(NSRange(location: 38, length: 2), controller.backingRange(presentationRange: NSRange(location: 11, length: 2)))
		XCTAssertEqual(NSRange(location: 21, length: 27), controller.backingRange(presentationRange: NSRange(location: 8, length: 7)))
	}

	func testBlockAtPresentationLocation() {
		controller.string = "⧙doc-heading⧘Title\nOne\n⧙blockquote⧘> Two"
		XCTAssertEqual("Title\nOne\nTwo", delegate.presentationString)

		XCTAssert(controller.blockAt(presentationLocation: 0)! is Title)
		XCTAssert(controller.blockAt(presentationLocation: 1)! is Title)
		XCTAssert(controller.blockAt(presentationLocation: 6)! is Paragraph)
		XCTAssert(controller.blockAt(presentationLocation: 7)! is Paragraph)
		XCTAssert(controller.blockAt(presentationLocation: 9)! is Paragraph)
		XCTAssert(controller.blockAt(presentationLocation: 10)! is Blockquote)
		XCTAssert(controller.blockAt(presentationLocation: 11)! is Blockquote)
	}

	func testPresentationStringWithBackingRange() {
		controller.string = "⧙doc-heading⧘Demo\nParagraph.\n⧙ordered-list-0⧘1. One"
		XCTAssertEqual("graph.\nOn", controller.presentationString(backingRange: NSRange(location: 22, length: 28)))
	}
}
