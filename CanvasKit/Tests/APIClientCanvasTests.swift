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
	func testCreateCanvas() {
		let expectation = expectationWithDescription("Networking")
		let dvr = Session(cassetteName: "create-canvas")
		let client = APIClient(accessToken: "REDACTED_TOKEN", session: dvr)

		client.createCanvas(collectionID: "test", body: "# From CanvasKit\nYay.") {
			switch $0 {
			case .Success(let canvas):
				print("canvas: \(canvas)")
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
		let client = APIClient(accessToken: "REDACTED_TOKEN", session: dvr)

		client.destroyCanvas(canvasID: "89480a5c-94fe-4fca-9a3d-faeff9f57154") {
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
		let client = APIClient(accessToken: "REDACTED_TOKEN", session: dvr)

		client.archiveCanvas(canvasID: "48565cf8-0471-4c6b-9655-aef5bcb0db8f") {
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
