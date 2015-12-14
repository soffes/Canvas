//
//  APIClient+Canvases.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/13/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

extension APIClient {

	// MARK: - Listing Canvases

	public func listCanvases(organization organization: Organization, completion: Result<[Canvas]> -> Void) {
		listCanvases(organizationID: organization.ID, completion: completion)
	}

	public func listCanvases(organizationID organizationID: String, completion: Result<[Canvas]> -> Void) {
		let request = self.request(path: "canvases", params: ["filter[collection]": organizationID])
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


	// MARK: - Creating a Canvas

	public func createCanvas(organization organization: Organization, body: String, completion: Result<Canvas> -> Void) {
		createCanvas(organizationID: organization.ID, body: body, completion: completion)
	}

	public func createCanvas(organizationID organizationID: String, body: String, completion: Result<Canvas> -> Void) {
		let request = self.request(method: .GET, path: "canvases", params: ["collection": organizationID], contentType: "text/plain")

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


	// MARK: - Destorying a Canvas

	public func destroyCanvas(canvas canvas: Canvas, completion: Result<Void> -> Void) {
		destroyCanvas(canvasID: canvas.ID, completion: completion)
	}

	public func destroyCanvas(canvasID canvasID: String, completion: Result<Void> -> Void) {
		let request = self.request(method: .DELETE, path: "canvases/\(canvasID)")
		session.dataTaskWithRequest(request) { _, response, _ in
			if let res = response as? NSHTTPURLResponse where res.statusCode == 204 {
				dispatch_async(networkCompletionQueue) {
					completion(.Success())
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Failure("Failed to destory Canvas."))
			}
		}.resume()
	}


	// MARK: - Archiving a Canvas

	public func archiveCanvas(canvas canvas: Canvas, completion: Result<Canvas> -> Void) {
		archiveCanvas(canvasID: canvas.ID, completion: completion)
	}

	public func archiveCanvas(canvasID canvasID: String, completion: Result<Canvas> -> Void) {
		let request = self.request(method: .PATCH, path: "canvases/\(canvasID)", params: [
			"data": [
				"archived": true
			]
		])

		session.dataTaskWithRequest(request) { responseData, response, _ in
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

			if let data = dictionary["data"] as? JSONDictionary, canvas = Canvas(dictionary: data) where canvas.archivedAt != nil {
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
