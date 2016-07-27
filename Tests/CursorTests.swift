//
//  CursorTests.swift
//  CanvasCoreTests
//
//  Created by Sam Soffes on 7/27/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
@testable import CanvasCore

class CursorTests: XCTestCase {
	func testRangeToCursor() {
		let string = "Hello\nOne\nTwo"
		let range = NSRange(location: 7, length: 5)

		let cursor = Cursor(selectedRange: range, string: string)!
		XCTAssertEqual(1, cursor.startLine)
		XCTAssertEqual(1, cursor.start)
		XCTAssertEqual(2, cursor.endLine)
		XCTAssertEqual(2, cursor.end)
	}
}
