//
//  OAuthClient.swift
//  CanvasKit
//
//  Created by Sam Soffes on 8/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

/// This client is soley used to obtain and revoke OAuth access tokens.
public struct OAuthClient: NetworkClient {

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


	// MARK: - Obtaining an Account with Access Token

	public func createAccessToken(username username: String, password: String, completion: Result<Account> -> Void) {
		let params = [
			NSURLQueryItem(name: "username", value: username),
			NSURLQueryItem(name: "password", value: password),
			NSURLQueryItem(name: "scope", value: "global"),
			NSURLQueryItem(name: "grant_type", value: "password")
		]

		let baseURL = self.baseURL
		let request = NSMutableURLRequest(URL: baseURL.URLByAppendingPathComponent("oauth/access-tokens"))
		request.HTTPMethod = "POST"
		request.HTTPBody = formEncode(params).dataUsingEncoding(NSUTF8StringEncoding)
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

		send(request: request, completion: completion)
	}


	/// Revoke an access token.
	///
	/// - parameter accessToken: The access token to revoke.
	/// - parameter completion: A function to call when the request finishes.
	/// Revoke an access token.
	///
	/// - parameter completion: A function to call when the request finishes.
	public func revokeAccessToken(accessToken: String, completion: (Result<Void> -> Void)? = nil) {
		let params = [
			NSURLQueryItem(name: "access_token", value: accessToken),
		]

		let baseURL = self.baseURL
		let request = NSMutableURLRequest(URL: baseURL.URLByAppendingPathComponent("oauth/access-tokens/actions/revoke"))
		request.HTTPMethod = "POST"
		request.HTTPBody = formEncode(params).dataUsingEncoding(NSUTF8StringEncoding)
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")

		send(request: request, completion: completion)
	}


	// MARK: - Private

	private func formEncode(queryItems: [NSURLQueryItem]) -> String {
		let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
		characterSet.addCharactersInString("-._~")

		return queryItems.flatMap { item -> String? in
			guard var output = item.name.stringByAddingPercentEncodingWithAllowedCharacters(characterSet) else { return nil }

			output += "="

			if let value = item.value?.stringByAddingPercentEncodingWithAllowedCharacters(characterSet) {
				output += value
			}

			return output
			}.joinWithSeparator("&")
	}

	private func authorizationHeader(username username: String, password: String) -> String? {
		guard let data = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)
			else { return nil }

		let base64 = data.base64EncodedStringWithOptions([])
		return "Basic \(base64)"
	}

	private func send(request request: NSMutableURLRequest, completion: (Result<Void> -> Void)?) {
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

		if let authorization = authorizationHeader(username: clientID, password: clientSecret) {
			request.setValue(authorization, forHTTPHeaderField: "Client-Authorization")
		} else {
			dispatch_async(networkCompletionQueue) {
				completion?(.Failure("Failed to create request"))
			}
			return
		}

		let session = self.session
		session.dataTaskWithRequest(request) { _, response, _ in
			guard let status = (response as? NSHTTPURLResponse)?.statusCode
			where status == 201
			else {
				dispatch_async(networkCompletionQueue) {
					completion?(.Failure("Invalid response."))
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion?(.Success())
			}
		}.resume()
	}

	private func send(request request: NSMutableURLRequest, completion: Result<Account> -> Void) {
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

		// Set the client credentials to the "Authorization" header per the OAuth spec
		if let authorization = authorizationHeader(username: clientID, password: clientSecret) {
			request.setValue(authorization, forHTTPHeaderField: "Authorization")
		} else {
			dispatch_async(networkCompletionQueue) {
				completion(.Failure("Failed to create request"))
			}
			return
		}

		let session = self.session
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

			// Log in
			if dictionary["access_token"] is String, let account = Account(dictionary: dictionary) {
				dispatch_async(networkCompletionQueue) {
					completion(.Success(account))
				}
				return
			}

			if let message = dictionary["message"] as? String {
				dispatch_async(networkCompletionQueue) {
					completion(.Failure(message))
				}
				return
			}

			if let error = dictionary["error"] as? String where error == "invalid_resource_owner" {
				dispatch_async(networkCompletionQueue) {
					completion(.Failure("Username/email or password incorrect."))
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Failure("Invalid response."))
			}
		}.resume()
	}
}
