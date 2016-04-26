//
//  ParagraphTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 3/11/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

class ParagraphTestes: XCTestCase {
	func testPreventNative() {
		let node = Paragraph(string: "⧙code⧘puts hi", range: NSRange(location: 0, length: 13))
		XCTAssertNil(node)
	}
}
