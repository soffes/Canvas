//
//  ImageTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/25/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

class ImageTests: XCTestCase {
	func testImage() {
		let native = "⧙image-{\"ci\":\"1-a-b\",\"width\":1011,\"height\":679,\"url\":\"https://example.com/cover.jpg\"}⧘"
		let length = native.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
		let image = Image(string: native, range: NSRange(location: 0, length: length), enclosingRange: NSRange(location: 0, length: length + 1))!

		XCTAssertEqual(NSRange(location: 0, length: length - 1), image.nativePrefixRange)
		XCTAssertEqual(NSRange(location: length - 1, length: 1), image.displayRange)
		XCTAssertEqual("1-a-b", image.ID)
		XCTAssertEqual(CGSize(width: 1011, height: 679), image.size)
		XCTAssertEqual(NSURL(string: "https://example.com/cover.jpg")!, image.URL)
	}
}
