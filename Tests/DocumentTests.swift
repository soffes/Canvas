//
//  DocumentTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 3/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

class DocumentTests: XCTestCase {
	func testTitle() {
		var document = Document(backingString: "⧙doc-heading⧘Title\nHello")
		XCTAssertEqual("Title", document.title)

		document = Document(backingString: "⧙doc-heading⧘**Title**\nHello")
		XCTAssertEqual("Title", document.title)
	}

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

	func testPresentationRangeForBlock() {
		let document = Document(backingString: "⧙doc-heading⧘Title\n⧙blockquote⧘> One")
		XCTAssertEqual(NSRange(location: 6, length: 3), document.presentationRange(block: document.blocks[1]))
		XCTAssertEqual(NSRange(location: 6, length: 3), document.presentationRange(blockIndex: 1))
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

	func testParsingInlineMarkers() {
		let document = Document(backingString: "⧙doc-heading⧘Title\nUn-markered text ☊co|3YA3fBfQystAGJj63asokU☋markered text☊Ωco|3YA3fBfQystAGJj63asokU☋un-markered text")
		XCTAssertEqual("Title\nUn-markered text markered textun-markered text", document.presentationString)

		let paragraph = document.blocks[1] as! Paragraph
		let pairs = [
			InlineMarkerPair(
				openingMarker: InlineMarker(range: NSRange(location: 36, length: 27), position: .Opening, id: "3YA3fBfQystAGJj63asokU"),
				closingMarker: InlineMarker(range: NSRange(location: 76, length: 28), position: .Closing, id: "3YA3fBfQystAGJj63asokU")
			)
		]
		XCTAssertEqual(pairs.map { $0.dictionary }, paragraph.inlineMarkerPairs.map { $0.dictionary })
	}

	func testPresentationRangeWithInlineMarkers() {
		var document = Document(backingString: "⧙doc-heading⧘Title\nUn-markered text ☊co|3YA3fBfQystAGJj63asokU☋markered text☊Ωco|3YA3fBfQystAGJj63asokU☋un-markered text\n⧙blockquote⧘> Hello")
		XCTAssertEqual(NSRange(location: 39, length: 8), document.presentationRange(backingRange: NSRange(location: 107, length: 8)))
		XCTAssertEqual(NSRange(location: 6, length: 46), document.presentationRange(backingRange: NSRange(location: 19, length: 101)))
		XCTAssertEqual(NSRange(location: 6, length: 46), document.presentationRange(blockIndex: 1))
		XCTAssertEqual(NSRange(location: 6, length: 46), document.presentationRange(block: document.blocks[1]))
		XCTAssertEqual(NSRange(location: 55, length: 2), document.presentationRange(backingRange: NSRange(location: 137, length: 2)))

		document = Document(backingString: "⧙doc-heading⧘Simple comments\nOne ☊co|6BsgU6S6zujYGINemEJwvi☋two☊Ωco|6BsgU6S6zujYGINemEJwvi☋\n⧙code-⧘Th☊co|0QgIo1DL4xqyTJlv2vuZb0☋r☊Ωco|0QgIo1DL4xqyTJlv2vuZb0☋ee")
		XCTAssertEqual(NSRange(location: 24, length: 5), document.presentationRange(blockIndex: 2))

	}

	func testBackingRangeWithInlineMarkers() {
		let document = Document(backingString: "⧙doc-heading⧘Title\nUn-markered text ☊co|3YA3fBfQystAGJj63asokU☋markered text☊Ωco|3YA3fBfQystAGJj63asokU☋un-markered text\n⧙blockquote⧘> Hello")
		XCTAssertEqual(NSRange(location: 107, length: 8), document.backingRange(presentationRange: NSRange(location: 39, length: 8)))
		XCTAssertEqual(NSRange(location: 19, length: 101), document.backingRange(presentationRange: NSRange(location: 6, length: 46)))
		XCTAssertEqual(NSRange(location: 137, length: 2), document.backingRange(presentationRange: NSRange(location: 55, length: 2)))
	}

	func testDeletingInlineMarkers() {
		let document = Document(backingString: "⧙doc-heading⧘Title\nOne ☊co|3YA3fBfQystAGJj63asokU☋two☊Ωco|3YA3fBfQystAGJj63asokU☋ three")

		// Insert at beginning, inserts outside marker
		XCTAssertEqual(NSRange(location: 23, length: 0), document.backingRange(presentationRange: NSRange(location: 10, length: 0)))

		// Insert at end, inserts inside marker
		XCTAssertEqual(NSRange(location: 53, length: 0), document.backingRange(presentationRange: NSRange(location: 13, length: 0)))

		// Delete last character, deletes inside marker
		XCTAssertEqual(NSRange(location: 52, length: 1), document.backingRange(presentationRange: NSRange(location: 12, length: 1)))

		// Delete first character, deletes inside marker
		XCTAssertEqual(NSRange(location: 50, length: 1), document.backingRange(presentationRange: NSRange(location: 10, length: 1)))

		// Delete before first character, deletes outside marker
		XCTAssertEqual(NSRange(location: 22, length: 1), document.backingRange(presentationRange: NSRange(location: 9, length: 1)))

		// Deleting the content of an inline marker deletes the whole marker
		XCTAssertEqual(NSRange(location: 23, length: 58), document.backingRange(presentationRange: NSRange(location: 10, length: 3)))
	}


	/*
		TODO:
		
		- [ ] New line at end of comment
		- [ ] New line in the middle of a comment
	*/
}
