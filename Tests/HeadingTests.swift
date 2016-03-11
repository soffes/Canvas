//
//  HeadingTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

class HeadingTest: XCTestCase {
	func testHeading1() {
		let node = Heading(string: "# Hello", range: NSRange(location: 0, length: 7), enclosingRange: NSRange(location: 0, length: 8))!
		XCTAssertEqual(NSRange(location: 0, length: 2), node.leadingDelimiterRange)
		XCTAssertEqual(NSRange(location: 2, length: 5), node.textRange)
		XCTAssertEqual(NSRange(location: 0, length: 7), node.visibleRange)
	}

	func testHeading2() {
		let node = Heading(string: "## Hello", range: NSRange(location: 0, length: 8), enclosingRange: NSRange(location: 0, length: 9))!
		XCTAssertEqual(NSRange(location: 0, length: 3), node.leadingDelimiterRange)
		XCTAssertEqual(NSRange(location: 3, length: 5), node.textRange)
		XCTAssertEqual(NSRange(location: 0, length: 8), node.visibleRange)
	}

	func testInvalid() {
		XCTAssertNil(Heading(string: "####### Hello", range: NSRange(location: 0, length: 13), enclosingRange: NSRange(location: 0, length: 14)))
		XCTAssertNil(Heading(string: "#Hello", range: NSRange(location: 0, length: 6), enclosingRange: NSRange(location: 0, length: 6)))
	}

	func testLevel() {
		XCTAssertEqual(Heading.Level.One, Heading.Level.One.predecessor)
		XCTAssertEqual(Heading.Level.One, Heading.Level.Two.predecessor)
		XCTAssertEqual(Heading.Level.Six, Heading.Level.Five.successor)
		XCTAssertEqual(Heading.Level.Six, Heading.Level.Six.successor)
	}

	func testOffset() {
		var node = Heading(string: "# Hello", range: NSRange(location: 0, length: 7), enclosingRange: NSRange(location: 0, length: 8))!
		node.offset(8)

		XCTAssertEqual(NSRange(location: 8, length: 2), node.leadingDelimiterRange)
		XCTAssertEqual(NSRange(location: 10, length: 5), node.textRange)
		XCTAssertEqual(NSRange(location: 8, length: 7), node.visibleRange)
	}

	func testNativeRepresentation() {
		XCTAssertEqual("# ", Heading.nativeRepresentation(level: .One))
		XCTAssertEqual("###### ", Heading.nativeRepresentation(level: .Six))
	}
}
