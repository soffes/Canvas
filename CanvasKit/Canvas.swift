//
//  Canvas.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/3/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

public struct Canvas {

	// MARK: - Properties

	public let ID: String
	public let shortID: String
	public let collectionID: String
	public let readOnly: Bool
	public let title: String?

	public var displayTitle: String {
		return title ?? "Untitled"
	}
}


extension Canvas: JSONSerializable, JSONDeserializable {
	public var dictionary: JSONDictionary {
		var dictionary: [String: AnyObject] = [
			"id": ID,
			"shortID": shortID,
			"collection_id": collectionID,
			"readonly": readOnly
		]

		if let title = title {
			dictionary["title"] = title
		}

		return dictionary
	}

	public init?(dictionary: JSONDictionary) {
		guard let ID = dictionary["id"] as? String,
			shortID = dictionary["shortID"] as? String,
			collectionID = dictionary["collection_id"] as? String,
			readOnly = dictionary["readonly"] as? Bool
		else { return nil }

		self.ID = ID
		self.shortID = shortID
		self.collectionID = collectionID
		self.readOnly = readOnly
		title = dictionary["title"] as? String
	}
}

