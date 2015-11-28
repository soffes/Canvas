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
		let client = APIClient(accessToken: "REDCATED_TOKEN", session: dvr)

		client.createCanvas(collectionID: "test", body: "# From CanvasKit\nYay.") {
			switch $0 {
			case .Success(let canvas):
				print("canvas: \(canvas)")
				// TODO: Assert that the title is what we expect
				XCTAssertEqual("4d9077a8-2f66-450a-9c51-db11b75f09fc", canvas.ID)
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
		let client = APIClient(accessToken: "REDCATED_TOKEN", session: dvr)

		client.destroyCanvas("d776c9ff-67b1-4f09-b762-acbaa2bbf124") {
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

