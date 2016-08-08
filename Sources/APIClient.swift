//
//  APIClient.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public class APIClient: NetworkClient {
	
	// MARK: - Types

	enum Method: String {
		case GET
		case HEAD
		case POST
		case PUT
		case DELETE
		case TRACE
		case OPTIONS
		case CONNECT
		case PATCH
	}
	
	
	// MARK: - Properties

	public let accessToken: String
	public let baseURL: NSURL
	public let session: NSURLSession

	
	// MARK: - Initializers
	
	public init(accessToken: String, baseURL: NSURL = CanvasKit.baseURL, session: NSURLSession = NSURLSession.sharedSession()) {
		self.accessToken = accessToken
		self.baseURL = baseURL
		self.session = session
	}


	// MARK: - Requests

	public func shouldComplete<T>(request request: NSURLRequest, response: NSHTTPURLResponse?, data: NSData?, error: NSError?, completion: (Result<T> -> Void)?) -> Bool {
		if let error = error {
			dispatch_async(networkCompletionQueue) {
				completion?(.Failure(error.localizedFailureReason ?? "Error"))
			}
			return false
		}

		return true
	}


	// MARK: - Organizations

	/// List organizations.
	///
	/// - parameter completion: A function to call when the request finishes.
	public func listOrganizations(completion: Result<[Organization]> -> Void) {
		request(path: "orgs", completion: completion)
	}

	// MARK: - Canvases

	/// Show a canvas.
	///
	/// - parameter id: The canvas ID.
	/// - parameter completion: A function to call when the request finishes.
	public func showCanvas(id id: String, completion: Result<Canvas> -> Void) {
		request(path: "canvases/\(id)", parameters: ["include": "org"], completion: completion)
	}

	/// Create a canvas.
	///
	/// - parameter organizationID: The ID of the organization to own the created canvas.
	/// - parameter content: Optional content for the new canvas.
	/// - parameter isPublicWritable: Boolean indicating if the new canvas should be publicly writable.
	/// - parameter completion: A function to call when the request finishes.
	public func createCanvas(organizationID organizationID: String, content: String? = nil, isPublicWritable: Bool? = nil, completion: Result<Canvas> -> Void) {
		var attributes = JSONDictionary()

		if let content = content {
			attributes["content"] = content
		}

		if let isPublicWritable = isPublicWritable {
			attributes["is_public_writable"] = isPublicWritable
		}

		let params = [
			"data": [
				"type": "canvases",
				"attributes": attributes,
				"relationships": [
					"org": [
						"data": [
							"type": "orgs",
							"id": organizationID
						]
					]
				]
			],
			"include": "org"
		]

		request(method: .POST, path: "canvases", parameters: params, completion: completion)
	}

	/// List canvases.
	///
	/// - parameter organizationID: Limit the results to a given organization.
	/// - parameter completion: A function to call when the request finishes.
	public func listCanvases(organizationID organizationID: String? = nil, completion: Result<[Canvas]> -> Void) {
		var params: JSONDictionary = [
			"include": "org"
		]

		if let organizationID = organizationID {
			params["filter[org.id]"] = organizationID
		}

		request(path: "canvases", parameters: params, completion: completion)
	}

	/// Search for canvases in an organization.
	///
	/// - parameter organizationID: The organization ID.
	/// - parameter query: The search query.
	/// - parameter completion: A function to call when the request finishes.
	public func searchCanvases(organizationID organizationID: String, query: String, completion: Result<[Canvas]> -> Void) {
		let params = [
			"query": query,
			"include": "org"
		]
		request(path: "orgs/\(organizationID)/actions/search", parameters: params, completion: completion)
	}

	/// Destroy a canvas.
	///
	/// - parameter id: The canvas ID.
	/// - parameter completion: A function to call when the request finishes.
	public func destroyCanvas(id id: String, completion: (Result<Void> -> Void)? = nil) {
		request(method: .DELETE, path: "canvases/\(id)", completion: completion)
	}

	/// Archive a canvas.
	///
	/// - parameter id: The canvas ID.
	/// - parameter completion: A function to call when the request finishes.
	public func archiveCanvas(id id: String, completion: (Result<Canvas> -> Void)? = nil) {
		canvasAction(name: "archive", id: id, completion: completion)
	}

	/// Unarchive a canvas.
	///
	/// - parameter id: The canvas ID.
	/// - parameter completion: A function to call when the request finishes.
	public func unarchiveCanvas(id id: String, completion: (Result<Canvas> -> Void)? = nil) {
		canvasAction(name: "unarchive", id: id, completion: completion)
	}

	/// Change public edits setting for a canvas.
	///
	/// - parameter id: The canvas ID.
	/// - parameter completion: A function to call when the request finishes.
	public func changePublicEdits(id id: String, enabled: Bool, completion: (Result<Canvas> -> Void)? = nil) {
		let params: JSONDictionary = [
			"data": [
				"attributes": [
					"is_public_writable": enabled
				]
			],
			"include": "org"
		]
		request(method: .PATCH, path: "canvases/\(id)", parameters: params, completion: completion)
	}

	
	// MARK: - Private

	private func request(method method: Method = .GET, path: String, parameters: JSONDictionary? = nil, contentType: String = "application/json; charset=utf-8", completion: (Result<Void> -> Void)?) {
		let request = buildRequest(method: method, path: path, parameters: parameters, contentType: contentType)
		sendRequest(request: request, completion: completion) { _, response, _ in
			print("response: \(response)")
			guard let completion = completion else { return }
			dispatch_async(networkCompletionQueue) {
				completion(.Success(()))
			}
		}
	}

	private func request<T: Resource>(method method: Method = .GET, path: String, parameters: JSONDictionary? = nil, contentType: String = "application/json; charset=utf-8", completion: (Result<[T]> -> Void)?) {
		let request = buildRequest(method: method, path: path, parameters: parameters, contentType: contentType)
		sendRequest(request: request, completion: completion) { data, _, _ in
			guard let completion = completion else { return }
			guard let data = data,
				json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
				dictionary = json as? JSONDictionary
			else {
				dispatch_async(networkCompletionQueue) {
					completion(.Failure("Invalid response"))
				}
				return
			}

			guard let values = ResourceSerialization.deserialize(dictionary: dictionary) as [T]? else {
				let errors = (dictionary["errors"] as? [JSONDictionary])?.flatMap { $0["detail"] as? String }
				let error = errors?.joinWithSeparator(" ")

				dispatch_async(networkCompletionQueue) {
					completion(.Failure(error ?? "Invalid response"))
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Success(values))
			}
		}
	}

	private func request<T: Resource>(method method: Method = .GET, path: String, parameters: JSONDictionary? = nil, contentType: String = "application/json; charset=utf-8", completion: (Result<T> -> Void)?) {
		let request = buildRequest(method: method, path: path, parameters: parameters, contentType: contentType)
		sendRequest(request: request, completion: completion) { data, _, _ in
			guard let completion = completion else { return }
			guard let data = data,
				json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
				dictionary = json as? JSONDictionary
				else {
					dispatch_async(networkCompletionQueue) {
						completion(.Failure("Invalid response"))
					}
					return
			}

			guard let value = ResourceSerialization.deserialize(dictionary: dictionary) as T? else {
				let errors = (dictionary["errors"] as? [JSONDictionary])?.flatMap { $0["detail"] as? String }
				let error = errors?.joinWithSeparator(" ")

				dispatch_async(networkCompletionQueue) {
					completion(.Failure(error ?? "Invalid response"))
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Success(value))
			}
		}
	}
	
	private func buildRequest(method method: Method = .GET, path: String, parameters: JSONDictionary? = nil, contentType: String = "application/json; charset=utf-8") -> NSMutableURLRequest {
		// Create URL
		var url = baseURL.URLByAppendingPathComponent(path)

		// Add GET params
		if method == .GET {
			if let parameters = parameters, components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true) {
				var queryItems = [NSURLQueryItem]()
				for (name, value) in parameters {
					if let value = value as? String {
						queryItems.append(NSURLQueryItem(name: name, value: value))
					} else {
						print("[APIClient] Failed to GET encode a non string value: `\(value)`")
					}
				}
				components.queryItems = queryItems

				if let updatedURL = components.URL {
					url = updatedURL
				}
			}
		}

		// Create request
		let request = NSMutableURLRequest(URL: url)

		// Set HTTP method
		request.HTTPMethod = method.rawValue

		// Add content type
		request.setValue(contentType, forHTTPHeaderField: "Content-Type")

		// Add POST params
		if let parameters = parameters where method != .GET {
			request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(parameters, options: [])
		}

		// Accept JSON
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

		// Add access token
		request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		
		return request
	}

	private func sendRequest<T>(request request: NSURLRequest, completion: (Result<T> -> Void)?, callback: (data: NSData?, response: NSHTTPURLResponse?, error: NSError?) -> Void) {
		session.dataTaskWithRequest(request) { data, res, error in
			let response = res as? NSHTTPURLResponse

			// We strongly capture self here on purpose so the client will last at least long enough for the
			// `shouldComplete` method to get called.
			guard self.shouldComplete(request: request, response: response, data: data, error: error, completion: completion) else { return }
			
			callback(data: data, response: response, error: error)
		}.resume()
	}

	private func canvasAction(name name: String, id: String, completion: (Result<Canvas> -> Void)?) {
		let path = "canvases/\(id)/actions/\(name)"
		let params = ["include": "org"]
		request(method: .POST, path: path, parameters: params, completion: completion)
	}
}
