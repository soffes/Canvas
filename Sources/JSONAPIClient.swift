//
//  JSONAPIClient.swift
//  CanvasKit
//
//  Created by Sam Soffes on 7/11/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

public final class JSONAPIClient: APIClient {
	public init(accessToken: String, session: NSURLSession = NSURLSession.sharedSession()) {
		let baseURL = NSURL(string: "https://canvas-json-api.herokuapp.com/")!
		super.init(accessToken: accessToken, baseURL: baseURL, session: session)
	}
	
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
