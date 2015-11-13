//
//  APIClient+Canvases.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/13/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

extension APIClient {
	public func createCanvas(collection collection: Collection, body: String, completion: Result<Canvas> -> Void) {
		createCanvas(collectionID: collection.ID, body: body, completion: completion)
	}

	public func createCanvas(collectionID collectionID: String, body: String, completion: Result<Canvas> -> Void) {
		let request = self.request(method: .GET, path: "canvases", params: ["collection": collectionID], contentType: "text/plain")

		// Switch method to POST. We originally use GET since there are GET params.
		request.HTTPMethod = "POST"

		// Attach the contents
		request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)

		session.dataTaskWithRequest(request) { responseData, response, error in
			if let response = response as? NSHTTPURLResponse where response.statusCode == 401 {
				dispatch_async(networkCompletionQueue) {
					completion(.Failure("Unauthorized"))
				}
				return
			}

			guard let responseData = responseData,
				json = try? NSJSONSerialization.JSONObjectWithData(responseData, options: []),
				dictionary = json as? JSONDictionary
				else {
					dispatch_async(networkCompletionQueue) {
						completion(.Failure("Invalid JSON"))
					}
					return
			}

			if let data = dictionary["data"] as? JSONDictionary, canvas = Canvas(dictionary: data) {
				dispatch_async(networkCompletionQueue) {
					completion(.Success(canvas))
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Failure("Invalid response"))
			}
		}.resume()
	}
}
