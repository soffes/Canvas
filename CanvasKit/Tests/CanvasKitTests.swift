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

class CanvasKitTests: XCTestCase {
	func testSignIn() {
		let expectation = expectationWithDescription("Networking")
		let dvr = Session(cassetteName: "sign-in")
		let client = APIClient(session: dvr)

		client.signIn("soffes", password: "REDACTED_PASSWORD") {
			switch $0 {
			case .Success(let account):
				XCTAssertEqual("REDACTED_TOKEN", account.accessToken)
			default:
				XCTFail()
			}
			expectation.fulfill()
		}

		waitForExpectationsWithTimeout(1, handler: nil)
	}

	func testListCollections() {
		let expectation = expectationWithDescription("Networking")
		let dvr = Session(cassetteName: "list-collections")
		let client = APIClient(session: dvr)
		client.accessToken = "REDACTED_TOKEN"

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
}
