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
	let document = Document(backingString: "⧙doc-heading⧘Cursor Test\nHello\n⧙unordered-list-0⧘- List item\n⧙blockquote⧘> This is a [link](http://example.com).\nThe end")

	func testRangeToCursorMulti() {
		let range = NSRange(location: 14, length: 55)
		let cursor = Cursor(presentationSelectedRange: range, document: document)!

		XCTAssertEqual(1, cursor.startLine)
		XCTAssertEqual(2, cursor.start)
		XCTAssertEqual(4, cursor.endLine)
		XCTAssertEqual(3, cursor.end)
	}

	func testCursorToRangeMulti() {
		let cursor = Cursor(startLine: 1, start: 2, endLine: 4, end: 3)
		XCTAssertEqual(NSRange(location: 14, length: 55), cursor.presentationRange(with: document))
	}

	func testRangeToCursorSingle() {
		let range = NSRange(location: 20, length: 1)
		let cursor = Cursor(presentationSelectedRange: range, document: document)!

		XCTAssertEqual(2, cursor.startLine)
		XCTAssertEqual(2, cursor.start)
		XCTAssertEqual(2, cursor.endLine)
		XCTAssertEqual(3, cursor.end)
	}

	func testCursorToRangeSingle() {
		let cursor = Cursor(startLine: 2, start: 2, endLine: 2, end: 3)
		XCTAssertEqual(NSRange(location: 20, length: 1), cursor.presentationRange(with: document))
	}

	func testRangeToCursorZero() {
		let range = NSRange(location: 0, length: 0)
		let cursor = Cursor(presentationSelectedRange: range, document: document)!

		XCTAssertEqual(0, cursor.startLine)
		XCTAssertEqual(0, cursor.start)
		XCTAssertEqual(0, cursor.endLine)
		XCTAssertEqual(0, cursor.end)
	}

	func testCursorToRangeZero() {
		let cursor = Cursor(startLine: 0, start: 0, endLine: 0, end: 0)
		XCTAssertEqual(NSRange(location: 0, length: 0), cursor.presentationRange(with: document))
	}

	func testRangeToCursorStart() {
		let range = NSRange(location: 12, length: 0)
		let cursor = Cursor(presentationSelectedRange: range, document: document)!

		XCTAssertEqual(1, cursor.startLine)
		XCTAssertEqual(0, cursor.start)
		XCTAssertEqual(1, cursor.endLine)
		XCTAssertEqual(0, cursor.end)
	}

	func testCursorToRangeStart() {
		let cursor = Cursor(startLine: 1, start: 0, endLine: 1, end: 0)
		XCTAssertEqual(NSRange(location: 12, length: 0), cursor.presentationRange(with: document))
	}

	func testRangeToCursorAll() {
		let range = NSRange(location: 0, length: 73)
		let cursor = Cursor(presentationSelectedRange: range, document: document)!

		XCTAssertEqual(0, cursor.startLine)
		XCTAssertEqual(0, cursor.start)
		XCTAssertEqual(4, cursor.endLine)
		XCTAssertEqual(7, cursor.end)
	}

	func testCursorToRangeAll() {
		let cursor = Cursor(startLine: 0, start: 0, endLine: 4, end: 7)
		XCTAssertEqual(NSRange(location: 0, length: 73), cursor.presentationRange(with: document))
	}
}
