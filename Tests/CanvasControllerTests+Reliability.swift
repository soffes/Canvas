//
//  CanvasControllerTests+Reliability.swift
//  CanvasNative
//
//  Created by Sam Soffes on 3/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
@testable import CanvasNative

extension CanvasControllerTests {
	func testReliabilityInsert() {
		controller.string = "⧙doc-heading⧘Title\nOne\nTwo"

		controller.replaceCharactersInRange(NSRange(location: 21, length: 0), withString: "1")
		XCTAssertEqual("⧙doc-heading⧘Title\nOn1e\nTwo", controller.string)
		XCTAssertEqual("Title\nOn1e\nTwo", delegate.presentationString)

		controller.replaceCharactersInRange(NSRange(location: 22, length: 0), withString: "2")
		XCTAssertEqual("⧙doc-heading⧘Title\nOn12e\nTwo", controller.string)
		XCTAssertEqual("Title\nOn12e\nTwo", delegate.presentationString)

		controller.replaceCharactersInRange(NSRange(location: 23, length: 0), withString: "3")
		XCTAssertEqual("⧙doc-heading⧘Title\nOn123e\nTwo", controller.string)
		XCTAssertEqual("Title\nOn123e\nTwo", delegate.presentationString)

		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}

	func testReliabilityDelete() {
		controller.string = "⧙doc-heading⧘Title\nOne...\nTwo"

		controller.replaceCharactersInRange(NSRange(location: 24, length: 1), withString: "")
		XCTAssertEqual("⧙doc-heading⧘Title\nOne..\nTwo", controller.string)
		XCTAssertEqual("Title\nOne..\nTwo", delegate.presentationString)

		controller.replaceCharactersInRange(NSRange(location: 23, length: 1), withString: "")
		XCTAssertEqual("⧙doc-heading⧘Title\nOne.\nTwo", controller.string)
		XCTAssertEqual("Title\nOne.\nTwo", delegate.presentationString)

		controller.replaceCharactersInRange(NSRange(location: 22, length: 1), withString: "")
		XCTAssertEqual("⧙doc-heading⧘Title\nOne\nTwo", controller.string)
		XCTAssertEqual("Title\nOne\nTwo", delegate.presentationString)

		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}

	func testReliabilityEnd() {
		controller.string = "⧙doc-heading⧘Title\nOne\nTwo"

		var presentationRange = NSRange(location: 13, length: 0)
		var backingRange = controller.backingRange(presentationRange: presentationRange)
		var replacement = "."
		var blockRange = controller.blockRangeForCharacterRange(backingRange, string: replacement)
		XCTAssertEqual(NSRange(location: 2, length: 1), blockRange)
		controller.replaceCharactersInRange(backingRange, withString: replacement)
		XCTAssertEqual("⧙doc-heading⧘Title\nOne\nTwo.", controller.string)
		XCTAssertEqual("Title\nOne\nTwo.", delegate.presentationString)
		XCTAssertEqual(parse(controller.string), blockDictionaries)
		
		presentationRange = NSRange(location: 13, length: 1)
		backingRange = controller.backingRange(presentationRange: presentationRange)
		replacement = ""
		blockRange = controller.blockRangeForCharacterRange(backingRange, string: replacement)
		XCTAssertEqual(NSRange(location: 2, length: 1), blockRange)
		controller.replaceCharactersInRange(backingRange, withString: "")
		XCTAssertEqual("⧙doc-heading⧘Title\nOne\nTwo", controller.string)
		XCTAssertEqual("Title\nOne\nTwo", delegate.presentationString)
		XCTAssertEqual(parse(controller.string), blockDictionaries)
	}
}
