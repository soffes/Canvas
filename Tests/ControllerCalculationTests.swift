//
//  DocumentCalculationTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 3/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

class DocumentCalculationTests: XCTestCase {
	func testBackingRangeToPresentationRange() {
		var document = Document(backingString: "⧙doc-heading⧘Title\nOne\n⧙blockquote⧘> Two\n⧙code⧘Three")

		XCTAssertEqual("Title\nOne\nTwo\nThree", document.presentationString)
		XCTAssertEqual(NSRange(location: 0, length: 5), document.presentationRange(backingRange: document.blocks[0].visibleRange))
		XCTAssertEqual(NSRange(location: 6, length: 3), document.presentationRange(backingRange: document.blocks[1].visibleRange))
		XCTAssertEqual(NSRange(location: 10, length: 3), document.presentationRange(backingRange: document.blocks[2].visibleRange))
		XCTAssertEqual(NSRange(location: 14, length: 5), document.presentationRange(backingRange: document.blocks[3].visibleRange))

		document = Document(backingString: "⧙doc-heading⧘Title\nO")
		XCTAssertEqual("Title\nO", document.presentationString)
		XCTAssertEqual(NSRange(location: 0, length: 5), document.presentationRange(backingRange: document.blocks[0].visibleRange))
		XCTAssertEqual(NSRange(location: 6, length: 1), document.presentationRange(backingRange: document.blocks[1].visibleRange))

		document = Document(backingString: "⧙doc-heading⧘Title\n⧙blockquote⧘> One")
		XCTAssertEqual("Title\nOne", document.presentationString)
		XCTAssertEqual(NSRange(location: 6, length: 3), document.presentationRange(backingRange: document.blocks[1].visibleRange))

		document = Document(backingString: "⧙doc-heading⧘Title\nC")
		XCTAssertEqual("Title\nC", document.presentationString)
		XCTAssertEqual(NSRange(location: 6, length: 1), document.presentationRange(backingRange: document.blocks[1].visibleRange))
	}

//	func testHiddenBackingRangeToPresentationRange() {
//		let document = Document(backingString: "⧙doc-heading⧘Title\n⧙blockquote⧘> Hi")
//
//		let backingRange = NSRange(location: 25, length: 5)
//		let displayRange = NSRange(location: 6, length: 0)
//		XCTAssertEqual(displayRange, document.presentationRange(backingRange: backingRange))
//	}

	func testPresentationRangeToBackingRange() {
		let document = Document(backingString: "⧙doc-heading⧘Title\nOne\n⧙blockquote⧘> Two\n⧙code⧘Three")
		XCTAssertEqual("Title\nOne\nTwo\nThree", document.presentationString)

		XCTAssertEqual(NSRange(location: 38, length: 2), document.backingRange(presentationRange: NSRange(location: 11, length: 2)))
		XCTAssertEqual(NSRange(location: 21, length: 27), document.backingRange(presentationRange: NSRange(location: 8, length: 7)))
	}

	func testEntirePresentationRange() {
		let document = Document(backingString: "⧙doc-heading⧘Title\n⧙image⧘http://example.com/image.jpg")
		let range = document.backingRange(presentationRange: NSRange(location: 6, length: 1))
		XCTAssertEqual(NSRange(location: 19, length: 35), range)
	}

	func testBlockAtPresentationLocation() {
		let document = Document(backingString: "⧙doc-heading⧘Title\nOne\n⧙blockquote⧘> Two")
		XCTAssertEqual("Title\nOne\nTwo", document.presentationString)

		XCTAssert(document.blockAt(presentationLocation: 0)! is Title)
		XCTAssert(document.blockAt(presentationLocation: 1)! is Title)
		XCTAssert(document.blockAt(presentationLocation: 6)! is Paragraph)
		XCTAssert(document.blockAt(presentationLocation: 7)! is Paragraph)
		XCTAssert(document.blockAt(presentationLocation: 9)! is Paragraph)
		XCTAssert(document.blockAt(presentationLocation: 10)! is Blockquote)
		XCTAssert(document.blockAt(presentationLocation: 11)! is Blockquote)
		XCTAssertNil(document.blockAt(presentationLocation: 14))
		XCTAssertNil(document.blockAt(presentationLocation: -1))
	}

	func testBlockAtPresentationLocationEmpty() {
		let document = Document(backingString: "⧙doc-heading⧘Great!\n⧙unordered-list-0⧘- This is a list\n\nOkay.")
		XCTAssertEqual("Great!\nThis is a list\n\nOkay.", document.presentationString)
		XCTAssertEqual(document.blockAt(presentationLocation: 22)!.range, document.blocks[2].range)
	}

	func testPresentationStringWithBackingRange() {
		let document = Document(backingString: "⧙doc-heading⧘Demo\nParagraph.\n⧙ordered-list-0⧘1. One")
		XCTAssertEqual("graph.\nOn", document.presentationString(backingRange: NSRange(location: 22, length: 28)))
	}
}
