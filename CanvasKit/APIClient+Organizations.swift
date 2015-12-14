//
//  APIClient+Organizations.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/13/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

extension APIClient {

	// MARK: - Listing Organizations

	public func listOrganizations(completion: Result<[Organization]> -> Void) {
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
				let organizations = data.flatMap({ Organization(dictionary: $0) })
				dispatch_async(networkCompletionQueue) {
					completion(.Success(organizations))
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Failure("Invalid response"))
			}
		}.resume()
	}


	// MARK: - Getting a Organization's Search Token

	public func getOrganizationSearchCredential(organization organization: Organization, completion: Result<SearchCredential> -> Void) {
		getOrganizationSearchCredential(organizationID: organization.ID, completion: completion)
	}

	public func getOrganizationSearchCredential(organizationID organizationID: String, completion: Result<SearchCredential> -> Void) {
		let params = [
			"data": [
				"collection": [
					"id": organizationID,
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
