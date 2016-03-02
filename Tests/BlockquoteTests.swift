//
//  BlockquoteTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

class BlockquoteTest: XCTestCase {
	func testBlockquote() {
		let node = Blockquote(string: "⧙blockquote⧘> Hello", range: NSRange(location: 0, length: 19), enclosingRange: NSRange(location: 0, length: 20))!
		XCTAssertEqual(NSRange(location: 0, length: 14), node.nativePrefixRange)
		XCTAssertEqual(NSRange(location: 14, length: 5), node.visibleRange)
	}
}
