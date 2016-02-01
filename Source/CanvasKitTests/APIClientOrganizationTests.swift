//
//  APIClientOrganizationTests.swift
//  CanvasKitTests
//
//  Created by Sam Soffes on 11/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import DVR
import CanvasKit

class APIClientOrganizationTests: XCTestCase {
	func testListOrganizations() {
		let expectation = expectationWithDescription("Networking")
		let dvr = Session(cassetteName: "list-organizations")
		let client = APIClient(accessToken: "REDACTED_TOKEN", session: dvr)

		client.listOrganizations {
			switch $0 {
			case .Success(let organizations):
				XCTAssertEqual(["soffes", "canvas"], organizations.map({ $0.name }))
			default:
				XCTFail()
			}
			expectation.fulfill()
		}

		waitForExpectationsWithTimeout(1, handler: nil)
	}

	func testGetOrganizationSearchCredential() {
		let expectation = expectationWithDescription("Networking")
		let dvr = Session(cassetteName: "search-credential")
		let client = APIClient(accessToken: "REDACTED_TOKEN", session: dvr)

		client.getOrganizationSearchCredential(organizationID: "soffes") {
			switch $0 {
			case .Success(let searchCredential):
				XCTAssertEqual("REDACTED_APPLICATION_ID", searchCredential.applicationID)
				XCTAssertEqual("REDACTED_SEARCH_KEY", searchCredential.searchKey)
			default:
				XCTFail()
			}
			expectation.fulfill()
		}

		waitForExpectationsWithTimeout(1, handler: nil)
	}
}
