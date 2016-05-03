//
//  SelectionControllerTests.swift
//  CanvasText
//
//  Created by Sam Soffes on 5/2/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
@testable import CanvasText

class SelectionControllerTests: XCTestCase {

	// MARK: - Properties

	private let startingSelection = NSRange(location: 10, length: 9)


	// MARK: - Insert Tests

	func testInsertBefore() {
		let output = SelectionController.adjust(
			selection: startingSelection,
			replacementRange: NSRange(location: 7, length: 0),
			replacementLength: 1
		)
		XCTAssertEqual(NSRange(location: 11, length: 9), output)
	}

	func testMultiInsertBefore() {
		let output = SelectionController.adjust(
			selection: startingSelection,
			replacementRange: NSRange(location: 7, length: 0),
			replacementLength: 5
		)
		XCTAssertEqual(NSRange(location: 15, length: 9), output)
	}

	func testInsertInside() {
		let output = SelectionController.adjust(
			selection: startingSelection,
			replacementRange: NSRange(location: 14, length: 0),
			replacementLength: 1
		)
		XCTAssertEqual(NSRange(location: 10, length: 10), output)
	}

	func testMultiInsertInside() {
		let output = SelectionController.adjust(
			selection: startingSelection,
			replacementRange: NSRange(location: 14, length: 0),
			replacementLength: 2
		)
		XCTAssertEqual(NSRange(location: 10, length: 11), output)
	}

	func testInsertAfter() {
		let output = SelectionController.adjust(
			selection: startingSelection,
			replacementRange: NSRange(location: 21, length: 0),
			replacementLength: 1
		)
		XCTAssertEqual(startingSelection, output)
	}

	func testMultiInsertAfter() {
		let output = SelectionController.adjust(
			selection: startingSelection,
			replacementRange: NSRange(location: 21, length: 0),
			replacementLength: 2
		)
		XCTAssertEqual(startingSelection, output)
	}


	// MARK: - Remove Tests

	func testRemoveBefore() {
		let output = SelectionController.adjust(
			selection: startingSelection,
			replacementRange: NSRange(location: 7, length: 1),
			replacementLength: 0
		)
		XCTAssertEqual(NSRange(location: 9, length: 9), output)
	}

	func testMultiRemoveBefore() {
		let output = SelectionController.adjust(
			selection: startingSelection,
			replacementRange: NSRange(location: 5, length: 3),
			replacementLength: 0
		)
		XCTAssertEqual(NSRange(location: 7, length: 9), output)
	}

	func testRemoveInside() {
		let output = SelectionController.adjust(
			selection: startingSelection,
			replacementRange: NSRange(location: 13, length: 1),
			replacementLength: 0
		)
		XCTAssertEqual(NSRange(location: 10, length: 8), output)
	}

	func testMultiRemoveInside() {
		let output = SelectionController.adjust(
			selection: startingSelection,
			replacementRange: NSRange(location: 13, length: 2),
			replacementLength: 0
		)
		XCTAssertEqual(NSRange(location: 10, length: 7), output)
	}

	func testRemoveAfter() {
		let output = SelectionController.adjust(
			selection: startingSelection,
			replacementRange: NSRange(location: 21, length: 1),
			replacementLength: 0
		)
		XCTAssertEqual(startingSelection, output)
	}

	func testMultiRemoveAfter() {
		let output = SelectionController.adjust(
			selection: startingSelection,
			replacementRange: NSRange(location: 21, length: 2),
			replacementLength: 0
		)
		XCTAssertEqual(startingSelection, output)
	}


	// MARK: - Replacement Tests

	func testReplaceBefore() {
		let output = SelectionController.adjust(
			selection: startingSelection,
			replacementRange: NSRange(location: 0, length: 4),
			replacementLength: 2
		)
		XCTAssertEqual(NSRange(location: 8, length: 9), output)
	}

	func testReplaceAfter() {
		let output = SelectionController.adjust(
			selection: startingSelection,
			replacementRange: NSRange(location: 20, length: 4),
			replacementLength: 2
		)
		XCTAssertEqual(NSRange(location: 10, length: 9), output)
	}


	// MARK: - Invalid Input Tests

	func testInvalid() {
		let output = SelectionController.adjust(
			selection: startingSelection,
			replacementRange: .zero,
			replacementLength: 0
		)
		XCTAssertEqual(startingSelection, output)
	}
}
