//
//  PlainRendererTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 6/9/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

final class PlainRendererTests: XCTestCase {
	func testRenderer() {
		let document = Document(backingString: "⧙doc-heading⧘Hello **world**\nHere's a [link](https://usecanvas.com).")
		let renderer = PlainRenderer(document: document)
		XCTAssertEqual("Hello world\nHere's a link.", renderer.render())
	}

	func testRendererWithInlineMarkers() {
		let document = Document(backingString: "⧙doc-heading⧘Hello **world**\nHere's ☊co|3YA3fBfQystAGJj63asokU☋a☊Ωco|3YA3fBfQystAGJj63asokU☋ [link](https://usecanvas.com).")
		let renderer = PlainRenderer(document: document)
		XCTAssertEqual("Hello world\nHere's a link.", renderer.render())
	}
}
