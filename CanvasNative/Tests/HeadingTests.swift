//
//  HeadingTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

final class HeadingTest: XCTestCase {
	func testHeading1() {
		let node = Heading(string: "# Hello", range: NSRange(location: 0, length: 7))!
		XCTAssertEqual(NSRange(location: 0, length: 2), node.leadingDelimiterRange)
		XCTAssertEqual(NSRange(location: 2, length: 5), node.textRange)
		XCTAssertEqual(NSRange(location: 0, length: 7), node.visibleRange)
		XCTAssertEqual([node.leadingDelimiterRange], node.foldableRanges)
	}

	func testHeading2() {
		let node = Heading(string: "## Hello", range: NSRange(location: 0, length: 8))!
		XCTAssertEqual(NSRange(location: 0, length: 3), node.leadingDelimiterRange)
		XCTAssertEqual(NSRange(location: 3, length: 5), node.textRange)
		XCTAssertEqual(NSRange(location: 0, length: 8), node.visibleRange)
	}

	func testInvalid() {
		XCTAssertNil(Heading(string: "####### Hello", range: NSRange(location: 0, length: 13)))
		XCTAssertNil(Heading(string: "#Hello", range: NSRange(location: 0, length: 6)))
	}

	func testLevel() {
		XCTAssertEqual(Heading.Level.one, Heading.Level.one.predecessor)
		XCTAssertEqual(Heading.Level.one, Heading.Level.two.predecessor)
		XCTAssertEqual(Heading.Level.six, Heading.Level.five.successor)
		XCTAssertEqual(Heading.Level.six, Heading.Level.six.successor)
	}

	func testOffset() {
		var node = Parser.parse("# Hello *World*").first! as! Heading
		node.offset(8)

		XCTAssertEqual(NSRange(location: 8, length: 2), node.leadingDelimiterRange)
		XCTAssertEqual(NSRange(location: 10, length: 13), node.textRange)
		XCTAssertEqual(NSRange(location: 8, length: 15), node.visibleRange)
		XCTAssertEqual(NSRange(location: 10, length: 6), node.subnodes[0].range)
		XCTAssertEqual(NSRange(location: 16, length: 7), node.subnodes[1].range)
	}

	func testNativeRepresentation() {
		XCTAssertEqual("# ", Heading.nativeRepresentation(level: .one))
		XCTAssertEqual("###### ", Heading.nativeRepresentation(level: .six))
	}
}
