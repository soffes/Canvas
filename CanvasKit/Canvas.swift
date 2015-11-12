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
	public let createdByID: String
	public let readOnly: Bool
}


extension Canvas: JSONSerializable, JSONDeserializable {
	public var dictionary: JSONDictionary {
		return [
			"id": ID,
			"shortID": shortID,
			"collection_id": collectionID,
			"created_by_id": createdByID,
			"readonly": readOnly
		]
	}

	public init?(dictionary: JSONDictionary) {
		guard let ID = dictionary["id"] as? String,
			shortID = dictionary["shortID"] as? String,
			collectionID = dictionary["collection_id"] as? String,
			createdByID = dictionary["created_by_id"] as? String,
			readOnly = dictionary["readonly"] as? Bool
		else { return nil }

		self.ID = ID
		self.shortID = shortID
		self.collectionID = collectionID
		self.createdByID = createdByID
		self.readOnly = readOnly
	}
}

