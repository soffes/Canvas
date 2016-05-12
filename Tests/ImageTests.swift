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
	func testUploadedImage() {
		let native = "⧙image-{\"ci\":\"1-a-b\",\"width\":1011,\"height\":679,\"url\":\"https://example.com/cover.jpg\"}⧘"
		let length = (native as NSString).length
		let image = Image(string: native, range: NSRange(location: 0, length: length))!

		XCTAssertEqual(NSRange(location: 0, length: length - 1), image.nativePrefixRange)
		XCTAssertEqual(NSRange(location: length - 1, length: 1), image.visibleRange)
		XCTAssertEqual("1-a-b", image.identifier)
		XCTAssertEqual(CGSize(width: 1011, height: 679), image.size)
		XCTAssertEqual(NSURL(string: "https://example.com/cover.jpg")!, image.url)
	}

	func testLinkedImage() {
		let native = "⧙image⧘https://canvas-files-prod.s3.amazonaws.com/uploads/b631973f-1d6f-4a27-8973-7c3db5c270fc/Screen Shot 2016-02-25 at 9.47.56 AM.png"
		let length = (native as NSString).length
		let image = Image(string: native, range: NSRange(location: 0, length: length))!

		XCTAssertEqual(NSRange(location: 0, length: length - 1), image.nativePrefixRange)
		XCTAssertEqual(NSRange(location: length - 1, length: 1), image.visibleRange)
		XCTAssertEqual(NSURL(string: "https://canvas-files-prod.s3.amazonaws.com/uploads/b631973f-1d6f-4a27-8973-7c3db5c270fc/Screen%20Shot%202016-02-25%20at%209.47.56%20AM.png")!, image.url)
	}
	
	func testNewLinkedImage() {
		let native = "⧙image-{\"url\":\"https://canvas-files-prod.s3.amazonaws.com/uploads/b631973f-1d6f-4a27-8973-7c3db5c270fc/Screen Shot 2016-02-25 at 9.47.56 AM.png\"}⧘"
		let length = (native as NSString).length
		let image = Image(string: native, range: NSRange(location: 0, length: length))!
		
		XCTAssertEqual(NSRange(location: 0, length: length - 1), image.nativePrefixRange)
		XCTAssertEqual(NSRange(location: length - 1, length: 1), image.visibleRange)
		XCTAssertEqual(NSURL(string: "https://canvas-files-prod.s3.amazonaws.com/uploads/b631973f-1d6f-4a27-8973-7c3db5c270fc/Screen%20Shot%202016-02-25%20at%209.47.56%20AM.png")!, image.url)
	}
}
