//
//  URLHelperTests.swift
//  CanvasCoreTests
//
//  Created by Sam Soffes on 6/19/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasCore

class URLHelperTests: XCTestCase {
	func testMatching() {
		let url = NSURL(string: "https://usecanvas.com/about/canvas/55h8GVkBfi5Lnr2Becv5tB")!
		XCTAssertEqual("55h8GVkBfi5Lnr2Becv5tB", URLHelper.canvasID(url: url))
	}

	func testExtension() {
		let url = NSURL(string: "https://usecanvas.com/about/canvas/55h8GVkBfi5Lnr2Becv5tB.json")!
		XCTAssertNil(URLHelper.canvasID(url: url))
	}
}
