//
//  AuthorizationClient.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/13/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

/// This client is used to create and verify an account.
public struct AuthorizationClient: NetworkClient {

	// MARK: - Properties

	public let clientID: String
	private let clientSecret: String
	public let baseURL: NSURL
	public let session: NSURLSession


	// MARK: - Initializers

	public init(clientID: String, clientSecret: String, baseURL: NSURL = CanvasKit.baseURL, session: NSURLSession = NSURLSession.sharedSession()) {
		self.clientID = clientID
		self.clientSecret = clientSecret
		self.baseURL = baseURL
		self.session = session
	}
	
	
	// MARK: - Creating an Account
	
	public func createAccount(email email: String, username: String, password: String, completion: Result<Void> -> Void) {
		let params = [
			"data": [
				"type": "account",
				"attributes": [
					"email": email,
					"password": password,
					"username": username
				]
			]
		]

		let request = self.request(path: "account", parameters: params)
		session.dataTaskWithRequest(request) { responseData, response, error in
			guard let responseData = responseData,
				json = try? NSJSONSerialization.JSONObjectWithData(responseData, options: []),
				dictionary = json as? JSONDictionary
			else {
				dispatch_async(networkCompletionQueue) {
					completion(.Failure("Invalid response."))
				}
				return
			}

			if let status = (response as? NSHTTPURLResponse)?.statusCode where status == 201 {
				dispatch_async(networkCompletionQueue) {
					completion(.Success())
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Failure(self.parseErrors(dictionary) ?? "Invalid response."))
			}
		}.resume()
	}
	
	public func verifyAccount(token token: String, completion: Result<Account> -> Void) {
		let params = [
			"data": [
				"type": "account",
				"attributes": [
					"verification_token": token
				]
			]
		]

		let request = self.request(path: "account/actions/verify", parameters: params)
		session.dataTaskWithRequest(request) { responseData, response, error in
			guard let responseData = responseData,
				json = try? NSJSONSerialization.JSONObjectWithData(responseData, options: []),
				dictionary = json as? JSONDictionary
			else {
				dispatch_async(networkCompletionQueue) {
					completion(.Failure("Invalid response."))
				}
				return
			}

			if let account: Account = ResourceSerialization.deserialize(dictionary: dictionary) {
				dispatch_async(networkCompletionQueue) {
					completion(.Success(account))
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Failure(self.parseErrors(dictionary) ?? "Invalid response."))
			}
		}.resume()
	}


	// MARK: - Private

	private func request(path path: String, parameters: JSONDictionary) -> NSURLRequest {
		let request = NSMutableURLRequest(URL: baseURL.URLByAppendingPathComponent(path))
		request.HTTPMethod = "POST"
		request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(parameters, options: [])
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

		// Add the client authorization
		if let authorization = authorizationHeader(username: clientID, password: clientSecret) {
			request.setValue(authorization, forHTTPHeaderField: "Authorization")
		}

		return request
	}

	private func authorizationHeader(username username: String, password: String) -> String? {
		guard let data = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)
		else { return nil }

		let base64 = data.base64EncodedStringWithOptions([])
		return "Basic \(base64)"
	}

	private func parseErrors(dictionary: JSONDictionary) -> String? {
		guard let errors = dictionary["errors"] as? [JSONDictionary] else { return nil }
		var errorMessages = [String]()

		for container in errors {
			guard let meta = container["meta"] as? JSONDictionary else { continue }

			for (key, values) in meta {
				guard let values = values as? [String] else { continue }

				for value in values {
					errorMessages.append("\(key.capitalizedString) \(value).")
				}
			}
		}

		guard !errorMessages.isEmpty else { return nil }

		return errorMessages.joinWithSeparator(" ")
	}
}
