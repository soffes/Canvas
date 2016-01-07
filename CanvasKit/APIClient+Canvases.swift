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
		let request = self.request(path: "orgs/\(organizationID)/canvases")
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

			let canvases = dictionaries.flatMap({ Canvas(dictionary: $0) })
			dispatch_async(networkCompletionQueue) {
				completion(.Success(canvases))
			}
		}.resume()
	}


	// MARK: - Creating a Canvas

	public func createCanvas(organization organization: Organization, body: String, completion: Result<Canvas> -> Void) {
		createCanvas(organizationID: organization.ID, body: body, completion: completion)
	}

	public func createCanvas(organizationID organizationID: String, body: String, completion: Result<Canvas> -> Void) {
		let params = [
			"orgs": [
				"id": organizationID
			]
		]
		let request = self.request(method: .POST, path: "canvases", params: params, contentType: "text/plain")

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
				dictionary = json as? JSONDictionary,
				canvas = Canvas(dictionary: dictionary)
				else {
					dispatch_async(networkCompletionQueue) {
						completion(.Failure("Invalid JSON"))
					}
					return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Success(canvas))
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
		let request = self.request(method: .POST, path: "canvases/\(canvasID)/actions/archive")

		session.dataTaskWithRequest(request) { responseData, response, _ in
			if let response = response as? NSHTTPURLResponse where response.statusCode == 401 {
				dispatch_async(networkCompletionQueue) {
					completion(.Failure("Unauthorized"))
				}
				return
			}

			guard let responseData = responseData,
				json = try? NSJSONSerialization.JSONObjectWithData(responseData, options: []),
				dictionary = json as? JSONDictionary,
				canvas = Canvas(dictionary: dictionary)
			where canvas.archivedAt != nil
			else {
				dispatch_async(networkCompletionQueue) {
					completion(.Failure("Invalid JSON"))
				}
				return
			}

			dispatch_async(networkCompletionQueue) {
				completion(.Success(canvas))
			}
		}.resume()
	}
}
