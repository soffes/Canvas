//
//  TitleTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 4/13/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

class TitleTest: XCTestCase {
	func testTitle() {
		let node = Title(string: "⧙doc-heading⧘Hello", range: NSRange(location: 0, length: 18))!
		XCTAssertEqual(NSRange(location: 0, length: 13), node.nativePrefixRange)
		XCTAssertEqual(NSRange(location: 13, length: 5), node.visibleRange)
	}

	func testInline() {
		let node = Parser.parse("⧙doc-heading⧘Hello **world**").first! as! Title
		XCTAssertEqual(NSRange(location: 13, length: 15), node.textRange)
		XCTAssert(node.subnodes[0] is Text)
		XCTAssert(node.subnodes[1] is DoubleEmphasis)
	}

	func testTrailingNewLine() {
		let blocks = Parser.parse("⧙doc-heading⧘Hello\n")

		XCTAssert(blocks[0] is Title)
		XCTAssertEqual(NSRange(location: 0, length: 18), blocks[0].range)

		XCTAssertEqual(2, blocks.count)
//		XCTAssert(blocks[1] is Paragraph)
//		XCTAssertEqual(NSRange(location: 19, length: 0), blocks[1].range)
	}
}
