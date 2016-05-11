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
		let request = self.request(path: "v1/orgs")
		session.dataTaskWithRequest(request) { responseData, response, error in
			if let response = response as? NSHTTPURLResponse where response.statusCode == 401 {
				dispatch_async(networkCompletionQueue) {
					completion(.Failure("Unauthorized"))
				}
				return
			}

			guard let responseData = responseData,
				json = try? NSJSONSerialization.JSONObjectWithData(responseData, options: []),
				dictionaries = json as? [JSONDictionary]
			else {
				dispatch_async(networkCompletionQueue) {
					completion(.Failure("Invalid JSON"))
				}
				return
			}

			let organizations = dictionaries.flatMap(Organization.init)
			dispatch_async(networkCompletionQueue) {
				completion(.Success(organizations))
			}
		}.resume()
	}
}
