//
//  DocumentInlineMarkerTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 6/20/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

// - [ ] New line before a comment
// - [ ] New line at end of comment
// - [ ] New line in the middle of a comment

final class DocumentInlineMarkerTests: XCTestCase {
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
		XCTAssertEqual([NSRange(location: 107, length: 8)], document.backingRanges(presentationRange: NSRange(location: 39, length: 8)))
		XCTAssertEqual([NSRange(location: 19, length: 101)], document.backingRanges(presentationRange: NSRange(location: 6, length: 46)))
		XCTAssertEqual([NSRange(location: 137, length: 2)], document.backingRanges(presentationRange: NSRange(location: 55, length: 2)))
	}

	func testDeletingInlineMarkers() {
		let document = Document(backingString: "⧙doc-heading⧘Title\nOne ☊co|3YA3fBfQystAGJj63asokU☋two☊Ωco|3YA3fBfQystAGJj63asokU☋ three")

		// Insert at beginning, inserts outside marker
		XCTAssertEqual(NSRange(location: 23, length: 0), document.backingRange(presentationLocation: 10))
		XCTAssertEqual([NSRange(location: 23, length: 0)], document.backingRanges(presentationRange: NSRange(location: 10, length: 0)))

		// Insert at end, inserts inside marker
		XCTAssertEqual(NSRange(location: 53, length: 0), document.backingRange(presentationLocation: 13))
		XCTAssertEqual([NSRange(location: 53, length: 0)], document.backingRanges(presentationRange: NSRange(location: 13, length: 0)))

		// Delete last character, deletes inside marker
		XCTAssertEqual([NSRange(location: 52, length: 1)], document.backingRanges(presentationRange: NSRange(location: 12, length: 1)))

		// Delete first character, deletes inside marker
		XCTAssertEqual([NSRange(location: 50, length: 1)], document.backingRanges(presentationRange: NSRange(location: 10, length: 1)))

		// Delete before first character, deletes outside marker
		XCTAssertEqual([NSRange(location: 22, length: 1)], document.backingRanges(presentationRange: NSRange(location: 9, length: 1)))

		// Deleting the content of an inline marker deletes the whole marker
		XCTAssertEqual([NSRange(location: 23, length: 58)], document.backingRanges(presentationRange: NSRange(location: 10, length: 3)))

		// Deleting partially inside and partially outside leaves marker intact
		let ranges = [
			NSRange(location: 21, length: 2),
			NSRange(location: 50, length: 2)
		]
		XCTAssertEqual(ranges, document.backingRanges(presentationRange: NSRange(location: 8, length: 4)))
	}
}
