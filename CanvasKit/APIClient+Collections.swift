//
//  APIClient+Collections.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/13/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

extension APIClient {

	// MARK: - Listing Collections

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


	// MARK: - Getting a Collection's Search Token

	public func getCollectionSearchCredential(collection collection: Collection, completion: Result<SearchCredential> -> Void) {
		getCollectionSearchCredential(collectionID: collection.ID, completion: completion)
	}

	public func getCollectionSearchCredential(collectionID collectionID: String, completion: Result<SearchCredential> -> Void) {
		let params = [
			"data": [
				"collection": [
					"id": collectionID,
					"type": "collections"
				],
				"type": "search-keys"
			]
		]

		let request = self.request(method: .POST, path: "search-tokens", params: params)

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

			if let data = dictionary["data"] as? JSONDictionary, credential = SearchCredential(dictionary: data) {
				dispatch_async(networkCompletionQueue) {
					completion(.Success(credential))
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Failure("Invalid response"))
			}
		}.resume()
	}
}
