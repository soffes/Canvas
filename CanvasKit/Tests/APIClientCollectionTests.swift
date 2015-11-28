//
//  APIClientCollectionTests.swift
//  CanvasKitTests
//
//  Created by Sam Soffes on 11/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import DVR
import CanvasKit

class APIClientCollectionTests: XCTestCase {
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

	func testListCanvases() {
		let expectation = expectationWithDescription("Networking")
		let dvr = Session(cassetteName: "list-canvases")
		let client = APIClient(accessToken: "REDACTED_TOKEN", session: dvr)

		client.listCanvases(collectionID: "soffes") {
			switch $0 {
			case .Success(let canvases):
				XCTAssertEqual(["Canvas Things", "Swift Vitamins Ideas", "Swift Summit Presentation"], canvases.flatMap({ $0.title }))
			default:
				XCTFail()
			}
			expectation.fulfill()
		}

		waitForExpectationsWithTimeout(1, handler: nil)
	}
}
