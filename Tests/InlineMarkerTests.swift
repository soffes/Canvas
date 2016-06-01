//
//  InlineMarkerTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 6/1/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

class InlineMarkerTests: XCTestCase {
	func testParsing() {
		let opening = InlineMarker(string: "☊co|3YA3fBfQystAGJj63asokU☋")!
		XCTAssertEqual(InlineMarker.Kind.Comment, opening.kind)
		XCTAssertEqual("3YA3fBfQystAGJj63asokU", opening.id)
		XCTAssertEqual(InlineMarker.Position.Opening, opening.position)

		let closing = InlineMarker(string: "☊Ωco|3YA3fBfQystAGJj63asokU☋")!
		XCTAssertEqual(InlineMarker.Kind.Comment, closing.kind)
		XCTAssertEqual("3YA3fBfQystAGJj63asokU", closing.id)
		XCTAssertEqual(InlineMarker.Position.Closing, closing.position)
	}
}
