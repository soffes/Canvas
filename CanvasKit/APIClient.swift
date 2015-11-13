//
//  APIClient.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public enum APIResult<T> {
	case Success(T)
	case Failure(String)
}


public class APIClient {
	
	// MARK: - Types
	
	private enum Method: String {
		case GET
		case POST
	}
	
	
	// MARK: - Properties
	
	public let baseURL: NSURL
	public let session: NSURLSession
	public var accessToken: String?
	
	public static let sharedClient = APIClient()
	private static let completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

	
	// MARK: - Initializers
	
	public init(baseURL: NSURL = NSURL(string: "https://api.usecanvas.com")!, session: NSURLSession = NSURLSession.sharedSession()) {
		self.baseURL = baseURL
		self.session = session
	}
	
	
	// MARK: - Signing In
	
	public func signIn(username: String, password: String, completion: APIResult<Account> -> Void) {
		let body = [
			"data": [
				"user": [
					"username": username,
					"password": password
				],
				"long_lived": true
			]
		]
		
		let request = self.request(method: .POST, path: "tokens", params: body)
		session.dataTaskWithRequest(request) { [weak self] responseData, _, error in
			guard let responseData = responseData,
				json = try? NSJSONSerialization.JSONObjectWithData(responseData, options: []),
				dictionary = json as? JSONDictionary
			else {
				dispatch_async(APIClient.completionQueue) {
					completion(.Failure("Invalid JSON"))
				}
				return
			}
			
			if let data = dictionary["data"] as? JSONDictionary, accessToken = data["token"] as? String {
				dispatch_async(APIClient.completionQueue) {
					self?.accessToken = accessToken
					
					guard let request = self?.request(path: "account"), session = self?.session else {
						dispatch_async(APIClient.completionQueue) {
							completion(.Failure("Unable to fetch account"))
						}
						return
					}
					
					// Fetch user. Gross.
					session.dataTaskWithRequest(request) { responseData, _, _ in
						guard let responseData = responseData,
							json = try? NSJSONSerialization.JSONObjectWithData(responseData, options: []),
							dictionary = json as? JSONDictionary,
							data = dictionary["data"] as? JSONDictionary,
							user = User(dictionary: data)
						else {
							dispatch_async(APIClient.completionQueue) {
								completion(.Failure("Unable to fetch account"))
							}
							return
						}
						completion(.Success(Account(accessToken: accessToken, user: user)))
					}.resume()
				}
				return
			}
			
			if let errors = dictionary["errors"] as? [[String: String]], error = errors.first, message = error["detail"] {
				dispatch_async(APIClient.completionQueue) {
					completion(.Failure(message))
				}
				return
			}
			
			dispatch_async(APIClient.completionQueue) {
				completion(.Failure("Invalid response"))
			}
		}.resume()
	}

	
	// MARK: - Collections
	
	public func listCollections(completion: APIResult<[Collection]> -> Void) {
		let request = self.request(path: "collections")
		session.dataTaskWithRequest(request) { responseData, response, error in
			if let response = response as? NSHTTPURLResponse where response.statusCode == 401 {
				dispatch_async(APIClient.completionQueue) {
					completion(.Failure("Unauthorized"))
				}
				return
			}

			guard let responseData = responseData,
				json = try? NSJSONSerialization.JSONObjectWithData(responseData, options: []),
				dictionary = json as? JSONDictionary
			else {
				dispatch_async(APIClient.completionQueue) {
					completion(.Failure("Invalid JSON"))
				}
				return
			}

			if let data = dictionary["data"] as? [JSONDictionary] {
				let collections = data.flatMap({ Collection(dictionary: $0) })
				dispatch_async(APIClient.completionQueue) {
					completion(.Success(collections))
				}
				return
			}

			dispatch_async(APIClient.completionQueue) {
				completion(.Failure("Invalid response"))
			}
		}.resume()
	}

	public func listCanvases(collection: Collection, completion: APIResult<[Canvas]> -> Void) {
		let request = self.request(path: "canvases", params: ["filter[collection]": collection.ID])
		session.dataTaskWithRequest(request) { responseData, response, error in
			if let response = response as? NSHTTPURLResponse where response.statusCode == 401 {
				dispatch_async(APIClient.completionQueue) {
					completion(.Failure("Unauthorized"))
				}
				return
			}

			guard let responseData = responseData,
				json = try? NSJSONSerialization.JSONObjectWithData(responseData, options: []),
				dictionary = json as? JSONDictionary
				else {
					dispatch_async(APIClient.completionQueue) {
						completion(.Failure("Invalid JSON"))
					}
					return
			}

			if let data = dictionary["data"] as? [JSONDictionary] {
				let canvases = data.flatMap({ Canvas(dictionary: $0) })
				dispatch_async(APIClient.completionQueue) {
					completion(.Success(canvases))
				}
				return
			}

			dispatch_async(APIClient.completionQueue) {
				completion(.Failure("Invalid response"))
			}
		}.resume()
	}


	// MARK: - Uploading

	public func createCanvas(collection collection: Collection, contents: String, completion: APIResult<Canvas> -> Void) {
		let request = self.request(method: .GET, path: "canvases", params: ["collection": collection.name], contentType: "text/plain")

		// Switch method to POST. We originally use GET since there are GET params.
		request.HTTPMethod = "POST"

		// Attach the contents
		request.HTTPBody = contents.dataUsingEncoding(NSUTF8StringEncoding)

		session.dataTaskWithRequest(request) { responseData, response, error in
			if let response = response as? NSHTTPURLResponse where response.statusCode == 401 {
				dispatch_async(APIClient.completionQueue) {
					completion(.Failure("Unauthorized"))
				}
				return
			}

			guard let responseData = responseData,
				json = try? NSJSONSerialization.JSONObjectWithData(responseData, options: []),
				dictionary = json as? JSONDictionary
				else {
					dispatch_async(APIClient.completionQueue) {
						completion(.Failure("Invalid JSON"))
					}
					return
			}

			if let data = dictionary["data"] as? JSONDictionary, canvas = Canvas(dictionary: data) {
				dispatch_async(APIClient.completionQueue) {
					completion(.Success(canvas))
				}
				return
			}

			dispatch_async(APIClient.completionQueue) {
				completion(.Failure("Invalid response"))
			}
		}.resume()
	}

	
	// MARK: - Private
	
	private func request(method method: Method = .GET, path: String, params: JSONDictionary? = nil, contentType: String = "application/json") -> NSMutableURLRequest {
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
		if let accessToken = accessToken {
			request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		}
		
		return request
	}
}
