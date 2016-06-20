//
//  HorizontalRuleTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 4/19/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

final class HorizontalRuleTests: XCTestCase {
	func testParsing() {
		var native = "***"
		var range = NSRange(location: 0, length: (native as NSString).length)
		var block = HorizontalRule(string: native, range: range)!
		XCTAssertEqual(NSRange(location: 0, length: range.length - 1), block.nativePrefixRange)
		XCTAssertEqual(NSRange(location: range.length - 1, length: 1), block.visibleRange)

		native = "---"
		range = NSRange(location: 0, length: (native as NSString).length)
		block = HorizontalRule(string: native, range: range)!
		XCTAssertEqual(NSRange(location: 0, length: range.length - 1), block.nativePrefixRange)
		XCTAssertEqual(NSRange(location: range.length - 1, length: 1), block.visibleRange)

		native = "___"
		range = NSRange(location: 0, length: (native as NSString).length)
		block = HorizontalRule(string: native, range: range)!
		XCTAssertEqual(NSRange(location: 0, length: range.length - 1), block.nativePrefixRange)
		XCTAssertEqual(NSRange(location: range.length - 1, length: 1), block.visibleRange)

		native = " ***"
		range = NSRange(location: 0, length: (native as NSString).length)
		block = HorizontalRule(string: native, range: range)!
		XCTAssertEqual(NSRange(location: 0, length: range.length - 1), block.nativePrefixRange)
		XCTAssertEqual(NSRange(location: range.length - 1, length: 1), block.visibleRange)

		native = "  ***"
		range = NSRange(location: 0, length: (native as NSString).length)
		block = HorizontalRule(string: native, range: range)!
		XCTAssertEqual(NSRange(location: 0, length: range.length - 1), block.nativePrefixRange)
		XCTAssertEqual(NSRange(location: range.length - 1, length: 1), block.visibleRange)

		native = "   ***"
		range = NSRange(location: 0, length: (native as NSString).length)
		block = HorizontalRule(string: native, range: range)!
		XCTAssertEqual(NSRange(location: 0, length: range.length - 1), block.nativePrefixRange)
		XCTAssertEqual(NSRange(location: range.length - 1, length: 1), block.visibleRange)

		native = "_____________________________________"
		range = NSRange(location: 0, length: (native as NSString).length)
		block = HorizontalRule(string: native, range: range)!
		XCTAssertEqual(NSRange(location: 0, length: range.length - 1), block.nativePrefixRange)
		XCTAssertEqual(NSRange(location: range.length - 1, length: 1), block.visibleRange)

		native = " - - -"
		range = NSRange(location: 0, length: (native as NSString).length)
		block = HorizontalRule(string: native, range: range)!
		XCTAssertEqual(NSRange(location: 0, length: range.length - 1), block.nativePrefixRange)
		XCTAssertEqual(NSRange(location: range.length - 1, length: 1), block.visibleRange)

		native = " **  * ** * ** * **"
		range = NSRange(location: 0, length: (native as NSString).length)
		block = HorizontalRule(string: native, range: range)!
		XCTAssertEqual(NSRange(location: 0, length: range.length - 1), block.nativePrefixRange)
		XCTAssertEqual(NSRange(location: range.length - 1, length: 1), block.visibleRange)

		native = "-     -      -      -"
		range = NSRange(location: 0, length: (native as NSString).length)
		block = HorizontalRule(string: native, range: range)!
		XCTAssertEqual(NSRange(location: 0, length: range.length - 1), block.nativePrefixRange)
		XCTAssertEqual(NSRange(location: range.length - 1, length: 1), block.visibleRange)

		native = "- - - -    "
		range = NSRange(location: 0, length: (native as NSString).length)
		block = HorizontalRule(string: native, range: range)!
		XCTAssertEqual(NSRange(location: 0, length: range.length - 1), block.nativePrefixRange)
		XCTAssertEqual(NSRange(location: range.length - 1, length: 1), block.visibleRange)


		native = "+++"
		range = NSRange(location: 0, length: (native as NSString).length)
		XCTAssertNil(HorizontalRule(string: native, range: range))

		native = "==="
		range = NSRange(location: 0, length: (native as NSString).length)
		XCTAssertNil(HorizontalRule(string: native, range: range))

		native = "--"
		range = NSRange(location: 0, length: (native as NSString).length)
		XCTAssertNil(HorizontalRule(string: native, range: range))

		native = "__"
		range = NSRange(location: 0, length: (native as NSString).length)
		XCTAssertNil(HorizontalRule(string: native, range: range))

		native = "**"
		range = NSRange(location: 0, length: (native as NSString).length)
		XCTAssertNil(HorizontalRule(string: native, range: range))

		native = "    ***"
		range = NSRange(location: 0, length: (native as NSString).length)
		XCTAssertNil(HorizontalRule(string: native, range: range))

		native = "_ _ _ _ a"
		range = NSRange(location: 0, length: (native as NSString).length)
		XCTAssertNil(HorizontalRule(string: native, range: range))

		native = "a------"
		range = NSRange(location: 0, length: (native as NSString).length)
		XCTAssertNil(HorizontalRule(string: native, range: range))

		native = "---a---"
		range = NSRange(location: 0, length: (native as NSString).length)
		XCTAssertNil(HorizontalRule(string: native, range: range))

		native = " *-*"
		range = NSRange(location: 0, length: (native as NSString).length)
		XCTAssertNil(HorizontalRule(string: native, range: range))
	}
}

