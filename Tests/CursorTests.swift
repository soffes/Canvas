//
//  CursorTests.swift
//  CanvasCoreTests
//
//  Created by Sam Soffes on 7/27/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative
@testable import CanvasCore

class CursorTests: XCTestCase {
	let document = Document(document: "Hello\nOne\nTwo")

	func testRangeToCursorMulti() {
		let range = NSRange(location: 7, length: 5)
		let cursor = Cursor(selectedRange: range, document: document)!

		XCTAssertEqual(1, cursor.startLine)
		XCTAssertEqual(1, cursor.start)
		XCTAssertEqual(2, cursor.endLine)
		XCTAssertEqual(2, cursor.end)
	}

	func testCursorToRangeMulti() {
		let cursor = Cursor(startLine: 1, start: 1, endLine: 2, end: 2)
		XCTAssertEqual(NSRange(location: 7, length: 5), cursor.range(with: document))
	}

	func testRangeToCursorSingle() {
		let range = NSRange(location: 7, length: 1)
		let cursor = Cursor(selectedRange: range, document: document)!

		XCTAssertEqual(1, cursor.startLine)
		XCTAssertEqual(1, cursor.start)
		XCTAssertEqual(1, cursor.endLine)
		XCTAssertEqual(2, cursor.end)
	}

	func testCursorToRangeSingle() {
		let cursor = Cursor(startLine: 1, start: 1, endLine: 1, end: 2)
		XCTAssertEqual(NSRange(location: 7, length: 1), cursor.range(with: document))
	}

	func testRangeToCursorZero() {
		let range = NSRange(location: 0, length: 0)
		let cursor = Cursor(selectedRange: range, document: document)!

		XCTAssertEqual(0, cursor.startLine)
		XCTAssertEqual(0, cursor.start)
		XCTAssertEqual(0, cursor.endLine)
		XCTAssertEqual(0, cursor.end)
	}

	func testCursorToRangeZero() {
		let cursor = Cursor(startLine: 0, start: 0, endLine: 0, end: 0)
		XCTAssertEqual(NSRange(location: 0, length: 0), cursor.range(with: document))
	}
}
