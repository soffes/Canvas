//
//  APIClientCanvasTests.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/18/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import DVR
import CanvasKit

class APIClientCanvasTests: XCTestCase {
	func testListCanvases() {
		let expectation = expectationWithDescription("Networking")
		let dvr = Session(cassetteName: "list-canvases")
		let client = APIClient(accessToken: "REDACTED_ACCESS_TOKEN", session: dvr)

		client.listCanvases(organizationID: "soffes") {
			switch $0 {
			case .Success(let canvases):
				XCTAssertEqual(["Ducati Scrambler Tires", "Drums"], canvases.flatMap({ $0.title }))
			default:
				XCTFail()
			}
			expectation.fulfill()
		}

		waitForExpectationsWithTimeout(1, handler: nil)
	}
	
	func testCreateCanvas() {
		let expectation = expectationWithDescription("Networking")
		let dvr = Session(cassetteName: "create-canvas")
		let client = APIClient(accessToken: "REDACTED_ACCESS_TOKEN", session: dvr)

		client.createCanvas(organizationID: "test", content: "# From CanvasKit\nYay.") {
			switch $0 {
			case .Success(let canvas):
				XCTAssertEqual("From CanvasKit", canvas.title)
			default:
				XCTFail()
			}
			expectation.fulfill()
		}

		waitForExpectationsWithTimeout(1, handler: nil)
	}

	func testDestroyCanvas() {
		let expectation = expectationWithDescription("Networking")
		let dvr = Session(cassetteName: "destroy-canvas")
		let client = APIClient(accessToken: "REDACTED_ACCESS_TOKEN", session: dvr)

		client.destroyCanvas(canvasID: "2Kg8HUaQ4XPcu6erPy5XDA") {
			switch $0 {
			case .Success(_):
				expectation.fulfill()
			default:
				XCTFail()
			}
		}

		waitForExpectationsWithTimeout(1, handler: nil)
	}

	func testArchiveCanvas() {
		let expectation = expectationWithDescription("Networking")
		let dvr = Session(cassetteName: "archive-canvas")
		let client = APIClient(accessToken: "REDACTED_ACCESS_TOKEN", session: dvr)

		client.archiveCanvas(canvasID: "3tgucu7tbOM2qIvFWsnoI1") {
			switch $0 {
			case .Success(_):
				expectation.fulfill()
			default:
				XCTFail()
			}
		}

		waitForExpectationsWithTimeout(1, handler: nil)
	}
}
