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

	public func shouldComplete<T>(request request: NSURLRequest, response: NSHTTPURLResponse?, data: NSData?, error: NSError?, completion: Result<T> -> Void) -> Bool {
		if let error = error {
			dispatch_async(networkCompletionQueue) {
				completion(.Failure(error.localizedFailureReason ?? "Error"))
			}
			return false
		}

		return true
	}

	
	// MARK: - Internal

	func request(method method: Method = .GET, path: String, params: JSONDictionary? = nil, contentType: String = "application/json; charset=utf-8", completion: Result<Void> -> Void) {
		let request = buildRequest(method: method, path: path, params: params, contentType: contentType)
		sendRequest(request: request, completion: completion) { _, _, _ in
			dispatch_async(networkCompletionQueue) {
				completion(.Success(()))
			}
		}
	}

	func request<T: JSONDeserializable>(method method: Method = .GET, path: String, params: JSONDictionary? = nil, contentType: String = "application/json; charset=utf-8", completion: Result<T> -> Void) {
		let request = buildRequest(method: method, path: path, params: params, contentType: contentType)
		sendRequest(request: request, completion: completion) { data, _, _ in
			guard let data = data,
				json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
				dictionary = json as? JSONDictionary,
				value = T.init(dictionary: dictionary)
			else {
				dispatch_async(networkCompletionQueue) {
					completion(.Failure("Invalid response"))
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Success(value))
			}
		}
	}

	func request<T: JSONDeserializable>(method method: Method = .GET, path: String, params: JSONDictionary? = nil, contentType: String = "application/json; charset=utf-8", completion: Result<[T]> -> Void) {
		let request = buildRequest(method: method, path: path, params: params, contentType: contentType)
		sendRequest(request: request, completion: completion) { data, _, _ in
			guard let data = data,
				json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
				dictionaries = json as? [JSONDictionary]
				else {
					dispatch_async(networkCompletionQueue) {
						completion(.Failure("Invalid response"))
					}
					return
			}

			dispatch_async(networkCompletionQueue) {
				let values = dictionaries.flatMap(T.init)
				completion(.Success(values))
			}
		}
	}
	
	private func buildRequest(method method: Method = .GET, path: String, params: JSONDictionary? = nil, contentType: String = "application/json; charset=utf-8") -> NSMutableURLRequest {
		// Create URL
		var URL = baseURL.URLByAppendingPathComponent(path)

		// Add GET params
		if method == .GET {
			if let params = params, components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true) {
				var queryItems = [NSURLQueryItem]()
				for (name, value) in params {
					if let value = value as? String {
						queryItems.append(NSURLQueryItem(name: name, value: value))
					} else {
						print("[APIClient] Failed to GET encode a non string value: `\(value)`")
					}
				}
				components.queryItems = queryItems

				if let updatedURL = components.URL {
					URL = updatedURL
				}
			}
		}

		// Create request
		let request = NSMutableURLRequest(URL: URL)

		// Set HTTP method
		request.HTTPMethod = method.rawValue

		// Add content type
		request.setValue(contentType, forHTTPHeaderField: "Content-Type")

		// Add POST params
		if let params = params where method != .GET {
			request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(params, options: [])
		}

		// Accept JSON
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

		// Add access token
		request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		
		return request
	}

	private func sendRequest<T>(request request: NSURLRequest, completion: Result<T> -> Void, callback: (data: NSData?, response: NSHTTPURLResponse?, error: NSError?) -> Void) {
		session.dataTaskWithRequest(request) { [weak self] data, res, error in
			let response = res as? NSHTTPURLResponse
			guard let this = self where this.shouldComplete(request: request, response: response, data: data, error: error, completion: completion) else { return }
			callback(data: data, response: response, error: error)
		}.resume()
	}
}
