//
//  AuthorizationClient.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/13/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public class AuthorizationClient: NetworkClient {

	// MARK: - Properties

	public let baseURL: NSURL
	public let session: NSURLSession


	// MARK: - Initializers

	public init(baseURL: NSURL = CanvasKit.baseURL, session: NSURLSession = NSURLSession.sharedSession()) {
		self.baseURL = baseURL
		self.session = session
	}


	// MARK: - Signing In

	public func signIn(username username: String, password: String, completion: Result<Account> -> Void) {
		let body = [
			"data": [
				"user": [
					"username": username,
					"password": password
				],
				"long_lived": true
			]
		]

		let baseURL = self.baseURL
		let request = NSMutableURLRequest(URL: baseURL.URLByAppendingPathComponent("tokens"))
		request.HTTPMethod = "POST"
		request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(body, options: [])
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json", forHTTPHeaderField: "Accept")

		let session = self.session
		session.dataTaskWithRequest(request) { responseData, _, error in
			guard let responseData = responseData,
				json = try? NSJSONSerialization.JSONObjectWithData(responseData, options: []),
				dictionary = json as? JSONDictionary
			else {
				dispatch_async(networkCompletionQueue) {
					completion(.Failure("Invalid JSON"))
				}
				return
			}

			if let data = dictionary["data"] as? JSONDictionary, accessToken = data["token"] as? String {
				dispatch_async(networkCompletionQueue) {
					let client = APIClient(accessToken: accessToken, baseURL: baseURL, session: session)
					client.me(completion)
				}
				return
			}

			if let errors = dictionary["errors"] as? [[String: String]], error = errors.first, message = error["detail"] {
				dispatch_async(networkCompletionQueue) {
					completion(.Failure(message))
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Failure("Invalid response"))
			}
		}.resume()
	}
}
