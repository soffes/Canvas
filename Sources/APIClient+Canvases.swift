//
//  APIClient+Canvases.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/13/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

extension APIClient {

	// MARK: - Showing a Canvas

	public func showCanvas(canvasID canvasID: String, completion: Result<Canvas> -> Void) {
		request(path: "v1/canvases/\(canvasID)", completion: completion)
	}


	// MARK: - Listing Canvases

	public func listCanvases(organizationID organizationID: String, completion: Result<[Canvas]> -> Void) {
		request(path: "v1/orgs/\(organizationID)/canvases", completion: completion)
	}


	// MARK: - Creating a Canvas

	public func createCanvas(organizationID organizationID: String, content: String? = nil, isPublicWritable: Bool? = nil, completion: Result<Canvas> -> Void) {
		var params: JSONDictionary = [
			"org": [
				"id": organizationID
			]
		]

		if let content = content {
			params["content"] = content
		}

		if let isPublicWritable = isPublicWritable {
			params["is_public_writable"] = isPublicWritable
		}

		request(method: .POST, path: "v1/canvases", parameters: params, completion: completion)
	}


	// MARK: - Destorying a Canvas

	public func destroyCanvas(canvasID canvasID: String, completion: (Result<Void> -> Void)? = nil) {
		request(method: .DELETE, path: "v1/canvases/\(canvasID)", completion: completion)
	}


	// MARK: - Archiving & Unarchiving Canvases

	public func archiveCanvas(canvasID canvasID: String, completion: (Result<Canvas> -> Void)? = nil) {
		request(method: .POST, path: "v1/canvases/\(canvasID)/actions/archive", completion: completion)
	}

	public func unarchiveCanvas(canvasID canvasID: String, completion: (Result<Canvas> -> Void)? = nil) {
		request(method: .POST, path: "v1/canvases/\(canvasID)/actions/unarchive", completion: completion)
	}


	// MARK: - Allowing & Disallowing Public Edits

	public func enablePublicEdits(canvasID canvasID: String, completion: (Result<Canvas> -> Void)? = nil) {
		let params = [
			"is_public_writable": true
		]
		request(method: .PATCH, path: "v1/canvases/\(canvasID)", parameters: params, completion: completion)
	}

	public func disablePublicEdits(canvasID canvasID: String, completion: (Result<Canvas> -> Void)? = nil) {
		let params = [
			"is_public_writable": false
		]
		request(method: .PATCH, path: "v1/canvases/\(canvasID)", parameters: params, completion: completion)
	}


	// MARK: - Searching for Canvases

	public func searchCanvases(organizationID organizationID: String, query: String, completion: Result<[Canvas]> -> Void) {
		request(path: "v1/orgs/\(organizationID)/canvases/search", parameters: ["query": query], completion: completion)
	}
}
