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
	func testSignIn() {
		let expectation = expectationWithDescription("Networking")

		let dvr = Session(cassetteName: "sign-in")
		dvr.beginRecording()

		let client = AuthorizationClient(session: dvr)

		client.signIn(username: "soffes", password: "REDACTED_PASSWORD") {
			switch $0 {
			case .Success(let account):
				XCTAssertEqual("REDACTED_TOKEN", account.accessToken)
				XCTAssertEqual("soffes", account.user.username)
				XCTAssertEqual("sam@soff.es", account.user.email)
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
