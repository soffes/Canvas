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
		request(path: "v1/orgs/\(organizationID)/canvases", completion: completion)
	}


	// MARK: - Creating a Canvas

	public func createCanvas(organization organization: Organization, content: String? = nil, isPublicWritable: Bool? = nil, completion: Result<Canvas> -> Void) {
		createCanvas(organizationID: organization.ID, content: content, isPublicWritable: isPublicWritable, completion: completion)
	}

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

		request(method: .POST, path: "v1/canvases", params: params, completion: completion)
	}


	// MARK: - Destorying a Canvas

	public func destroyCanvas(canvas canvas: Canvas, completion: Result<Void> -> Void) {
		destroyCanvas(canvasID: canvas.ID, completion: completion)
	}

	public func destroyCanvas(canvasID canvasID: String, completion: Result<Void> -> Void) {
		request(method: .DELETE, path: "v1/canvases/\(canvasID)", completion: completion)
	}


	// MARK: - Archiving a Canvas

	public func archiveCanvas(canvas canvas: Canvas, completion: Result<Canvas> -> Void) {
		archiveCanvas(canvasID: canvas.ID, completion: completion)
	}

	public func archiveCanvas(canvasID canvasID: String, completion: Result<Canvas> -> Void) {
		request(method: .POST, path: "v1/canvases/\(canvasID)/actions/archive", completion: completion)
	}


	// MARK: - Searching for Canvases

	public func searchCanvases(organization organization: Organization, query: String, completion: Result<[Canvas]> -> Void) {
		searchCanvases(organizationID: organization.ID, query: query, completion: completion)
	}

	public func searchCanvases(organizationID organizationID: String, query: String, completion: Result<[Canvas]> -> Void) {
		request(path: "v1/orgs/\(organizationID)/canvases/search", params: ["query": query], completion: completion)
	}
}
