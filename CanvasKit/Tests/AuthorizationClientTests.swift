//
//  AuthorizationClientTests.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/13/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import DVR
import CanvasKit

class AuthorizationClientTests: XCTestCase {
	func testLogin() {
		let expectation = expectationWithDescription("Networking")

		let dvr = Session(cassetteName: "access-token")
		dvr.beginRecording()

		let client = AuthorizationClient(clientID: "REDACTED_CLIENT_ID", clientSecret: "REDCATED_CLIENT_SECRET", session: dvr)

		client.createAccessToken(username: "soffes", password: "REDACTED_PASSWORD") {
			switch $0 {
			case .Success(let account):
				XCTAssertEqual("REDCATED_ACCESS_TOKEN", account.accessToken)
				XCTAssertEqual("soffes", account.user.username)
				XCTAssertEqual("sam@soff.es", account.email)
			case .Failure(let message):
				XCTFail(message)
			}

			dvr.endRecording() {
				expectation.fulfill()
			}
		}

		waitForExpectationsWithTimeout(1, handler: nil)
	}
}
