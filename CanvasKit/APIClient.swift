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

	
	// MARK: - Internal
	
	func request(method method: Method = .GET, path: String, params: JSONDictionary? = nil, contentType: String = "application/json") -> NSMutableURLRequest {
		// Create URL
		var URL = baseURL.URLByAppendingPathComponent(path)

		// Add GET params
		if method == .GET {
			if let params = params, components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true) {
				var queryItems = [NSURLQueryItem]()
				for (name, value) in params {
					// TODO: Support things other than string dictionaries
					if let value = value as? String {
						queryItems.append(NSURLQueryItem(name: name, value: value))
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
		request.setValue("application/json", forHTTPHeaderField: "Accept")

		// Add access token
		request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		
		return request
	}
}
