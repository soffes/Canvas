//
//  APIClient+Collections.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/13/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

extension APIClient {
	public func listCollections(completion: Result<[Collection]> -> Void) {
		let request = self.request(path: "collections")
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

			if let data = dictionary["data"] as? [JSONDictionary] {
				let collections = data.flatMap({ Collection(dictionary: $0) })
				dispatch_async(networkCompletionQueue) {
					completion(.Success(collections))
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Failure("Invalid response"))
			}
		}.resume()
	}

	public func listCanvases(collection: Collection, completion: Result<[Canvas]> -> Void) {
		listCanvases(collectionID: collection.ID, completion: completion)
	}

	public func listCanvases(collectionID collectionID: String, completion: Result<[Canvas]> -> Void) {
		let request = self.request(path: "canvases", params: ["filter[collection]": collectionID])
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

			if let data = dictionary["data"] as? [JSONDictionary] {
				let canvases = data.flatMap({ Canvas(dictionary: $0) })
				dispatch_async(networkCompletionQueue) {
					completion(.Success(canvases))
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Failure("Invalid response"))
			}
		}.resume()
	}
}
