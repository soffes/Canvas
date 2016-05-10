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
	public let organization: Organization
	public let isWritable: Bool
	public let isPublicWritable: Bool
	public let title: String
	public let summary: String
	public let nativeVersion: String
	public let updatedAt: NSDate
	public let archivedAt: NSDate?

	public var isEmpty: Bool {
		return summary.isEmpty
	}

	public var URL: NSURL? {
		return NSURL(string: "https://usecanvas.com/\(organization.slug)/-/\(ID)")
	}
}


extension Canvas: JSONSerializable, JSONDeserializable {
	public var dictionary: JSONDictionary {
		var dictionary: [String: AnyObject] = [
			"id": ID,
			"collection": organization.dictionary,
			"is_writable": isWritable,
			"is_public_writable": isPublicWritable,
			"updated_at": updatedAt.ISO8601String()!,
			"title": title,
			"summary": summary,
			"native_version": nativeVersion
		]

		if let archivedAt = archivedAt {
			dictionary["archived_at"] = archivedAt.ISO8601String()
		}

		return dictionary
	}

	public init?(dictionary: JSONDictionary) {
		guard let ID = dictionary["id"] as? String,
			org = dictionary["org"] as? JSONDictionary,
			organization = Organization(dictionary: org),
			isWritable = dictionary["is_writable"] as? Bool,
			isPublicWritable = dictionary["is_public_writable"] as? Bool,
			updatedAtString = dictionary["updated_at"] as? String,
			updatedAt = NSDate(ISO8601String: updatedAtString),
			title = dictionary["title"] as? String,
			summary = dictionary["summary"] as? String,
			nativeVersion = dictionary["native_version"] as? String
		else { return nil }

		self.ID = ID
		self.organization = organization
		self.isWritable = isWritable
		self.isPublicWritable = isPublicWritable
		self.title = title
		self.summary = summary
		self.nativeVersion = nativeVersion
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
