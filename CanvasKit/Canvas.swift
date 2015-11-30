//
//  Canvas.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/3/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import ISO8601

public struct Canvas {

	// MARK: - Properties

	public let ID: String
	public let shortID: String
	public let collectionID: String
	public let readOnly: Bool
	public let title: String?
	public let createdAt: NSDate
	public let updatedAt: NSDate
	public let archivedAt: NSDate?

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
			"readonly": readOnly,
			"data": [
				"m": [
					"ctime": createdAt.timeIntervalSince1970 * 1000,
					"mtime": updatedAt.timeIntervalSince1970 * 1000
				]
			]
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
			readOnly = dictionary["readonly"] as? Bool,
			data = dictionary["data"] as? JSONDictionary,
			m = data["m"] as? JSONDictionary,
			createdAt = m["ctime"] as? NSTimeInterval,
			updatedAt = m["mtime"] as? NSTimeInterval
		else { return nil }

		self.ID = ID
		self.shortID = shortID
		self.collectionID = collectionID
		self.readOnly = readOnly
		title = dictionary["title"] as? String
		self.createdAt = NSDate(timeIntervalSince1970: createdAt / 1000)
		self.updatedAt = NSDate(timeIntervalSince1970: updatedAt / 1000)

		let archivedAtString = dictionary["archived_at"] as? String
		archivedAt = archivedAtString.flatMap { NSDate(ISO8601String: $0) }
	}
}
