//
//  CanvasKitTests.swift
//  CanvasKitTests
//
//  Created by Sam Soffes on 11/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import DVR
import CanvasKit

class APIClientTests: XCTestCase {
	func testListCollections() {
		let expectation = expectationWithDescription("Networking")
		let dvr = Session(cassetteName: "list-collections")
		let client = APIClient(accessToken: "REDACTED_TOKEN", session: dvr)

		client.listCollections {
			switch $0 {
			case .Success(let collections):
				XCTAssertEqual(["soffes", "canvas"], collections.map({ $0.name }))
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
		let client = APIClient(accessToken: "REDCATED_TOKEN", session: dvr)

		client.createCanvas(collectionID: "test", body: "# From CanvasKit\nYay.") {
			switch $0 {
			case .Success(let canvas):
				// TODO: Assert that the title is what we expect
				XCTAssertEqual("4d9077a8-2f66-450a-9c51-db11b75f09fc", canvas.ID)
			default:
				XCTFail()
			}
			expectation.fulfill()
		}

		waitForExpectationsWithTimeout(1, handler: nil)
	}
}
