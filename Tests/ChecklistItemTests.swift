//
//  ChecklistItemTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 4/26/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

final class ChecklistItemTests: XCTestCase {
	func testUncompleted() {
		let node = ChecklistItem(
			string: "⧙checklist-0⧘- [ ] Hello",
			range: NSRange(location: 0, length: 24)
		)!

		XCTAssertEqual(NSRange(location: 0, length: 24), node.range)
		XCTAssertEqual(NSRange(location: 0, length: 19), node.nativePrefixRange)
		XCTAssertEqual(NSRange(location: 19, length: 5), node.visibleRange)
		XCTAssertEqual(NSRange(location: 11, length: 1), node.indentationRange)
		XCTAssertEqual(Indentation.Zero, node.indentation)
		XCTAssertEqual(NSRange(location: 16, length: 1), node.stateRange)
		XCTAssertEqual(ChecklistItem.State.Unchecked, node.state)
	}

	func testCompleted() {
		let node = ChecklistItem(
			string: "⧙checklist-1⧘- [x] Done",
			range: NSRange(location: 10, length: 23)
		)!

		XCTAssertEqual(NSRange(location: 10, length: 19), node.nativePrefixRange)
		XCTAssertEqual(NSRange(location: 29, length: 4), node.visibleRange)
		XCTAssertEqual(Indentation.One, node.indentation)
		XCTAssertEqual(ChecklistItem.State.Checked, node.state)
	}
}
