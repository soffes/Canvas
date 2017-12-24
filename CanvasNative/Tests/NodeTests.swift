//
//  NodeTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/29/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

final class NodeTests: XCTestCase {
	func testOffset() {
		let before = Paragraph(string: "Hello", range: NSRange(location: 0, length: 5))!

		var after = before
		after.offset(8)

		XCTAssertEqual(NSRange(location: 8, length: 5), after.range)
	}
}
