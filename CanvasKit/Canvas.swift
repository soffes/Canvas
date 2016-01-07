//
//  Canvas.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/3/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import ISO8601

public struct Canvas: Model {

	// MARK: - Properties

	public let ID: String
	public let UUID: String
	public let organizationID: String
	public let readOnly: Bool
	public let title: String?
	public let summary: String?
	public let updatedAt: NSDate
	public let archivedAt: NSDate?

	public var displayTitle: String {
		return title ?? "Untitled"
	}

	public var URL: NSURL? {
		return NSURL(string: "https://usecanvas.com/\(organizationID)/-/\(ID)")
	}
}


extension Canvas: JSONSerializable, JSONDeserializable {
	public var dictionary: JSONDictionary {
		var dictionary: [String: AnyObject] = [
			"id": ID,
			"uuid": UUID,
			"collection_id": organizationID,
			"readonly": readOnly,
			"updated_at": updatedAt.ISO8601String()!
		]

		if let title = title {
			dictionary["title"] = title
		}

		if let archivedAt = archivedAt {
			dictionary["archived_at"] = archivedAt.ISO8601String()
		}

		return dictionary
	}

	public init?(dictionary: JSONDictionary) {
		guard let ID = dictionary["id"] as? String,
			UUID = dictionary["uuid"] as? String,
			org = dictionary["org"] as? JSONDictionary,
			organizationID = org["id"] as? String,
			readOnly = dictionary["readonly"] as? Bool,
			updatedAtString = dictionary["updated_at"] as? String,
			updatedAt = NSDate(ISO8601String: updatedAtString)
		else { return nil }

		self.ID = ID
		self.UUID = UUID
		self.organizationID = organizationID
		self.readOnly = readOnly
		title = dictionary["title"] as? String
		summary = dictionary["summary"] as? String
		self.updatedAt = updatedAt

		let archivedAtString = dictionary["archived_at"] as? String
		archivedAt = archivedAtString.flatMap { NSDate(ISO8601String: $0) }
	}
}


extension Canvas: Hashable {
	public var hashValue: Int {
		return ID.hashValue
	}
}


public func ==(lhs: Canvas, rhs: Canvas) -> Bool {
	return lhs.ID == rhs.ID
}
