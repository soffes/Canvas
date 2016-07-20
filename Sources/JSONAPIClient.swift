//
//  JSONAPIClient.swift
//  CanvasKit
//
//  Created by Sam Soffes on 7/11/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

public class JSONAPIClient: APIClient {
	override func request<T: Resource>(method method: Method = .GET, path: String, parameters: JSONDictionary? = nil, contentType: String = "application/json; charset=utf-8", completion: (Result<[T]> -> Void)?) {
		let request = buildRequest(method: method, path: path, parameters: parameters, contentType: contentType)
		sendRequest(request: request, completion: completion) { data, _, _ in
			guard let completion = completion else { return }
			guard let data = data,
				json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
				dictionary = json as? JSONDictionary,
				values = ResourceSerialization.deserialize(dictionary: dictionary) as [T]?
			else {
				dispatch_async(networkCompletionQueue) {
					completion(.Failure("Invalid response"))
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Success(values))
			}
		}
	}

	override func request<T: Resource>(method method: Method = .GET, path: String, parameters: JSONDictionary? = nil, contentType: String = "application/json; charset=utf-8", completion: (Result<T> -> Void)?) {
		let request = buildRequest(method: method, path: path, parameters: parameters, contentType: contentType)
		sendRequest(request: request, completion: completion) { data, _, _ in
			guard let completion = completion else { return }
			guard let data = data,
				json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
				dictionary = json as? JSONDictionary,
				values = ResourceSerialization.deserialize(dictionary: dictionary) as T?
			else {
				dispatch_async(networkCompletionQueue) {
					completion(.Failure("Invalid response"))
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Success(values))
			}
		}
	}


	// MARK: - Canvases

	/// Show a canvas.
	///
	/// - parameter id: The canvas ID.
	/// - parameter completion: A function to call when the request finishes.
	public func canvas(id id: String, completion: Result<Canvas> -> Void) {
		request(path: "canvases", parameters: ["include": "org"], completion: completion)
	}

	/// List canvases.
	///
	/// - parameter organizationID: Limit the results to a given organization.
	/// - parameter completion: A function to call when the request finishes.
	public func canvases(organizationID organizationID: String? = nil, completion: Result<[Canvas]> -> Void) {
		var params: JSONDictionary = [
			"include": "org"
		]

		if let organizationID = organizationID {
			params["filter[org.id]"] = organizationID
		}
		
		request(path: "canvases", parameters: params, completion: completion)
	}
}
