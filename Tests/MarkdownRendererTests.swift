//
//  MarkdownRendererTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 7/25/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

final class MarkdownRendererTests: XCTestCase {
	func testRenderer() {
		let document = Document(backingString: "⧙doc-heading⧘Output\nHello\nThere\n⧙unordered-list-0⧘- This\n⧙unordered-list-0⧘- is\n⧙unordered-list-0⧘- a\n⧙unordered-list-0⧘- list\nMore after that.")
		let renderer = MarkdownRenderer(document: document)
		XCTAssertEqual("# Output\n\nHello\n\nThere\n\n- This\n- is\n- a\n- list\n\nMore after that.\n", renderer.render())
	}
}
