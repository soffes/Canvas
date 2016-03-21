//
//  Organization.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/3/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

public struct Organization {

	// MARK: - Properties

	public let ID: String
	public let name: String
	public let slug: String
	public let membersCount: UInt
	public let color: Color?
}


extension Organization: JSONSerializable, JSONDeserializable {
	public var dictionary: JSONDictionary {
		var dictionary: JSONDictionary = [
			"id": ID,
			"name": name,
			"slug": slug,
			"members_count": membersCount
		]

		if let color = color {
			dictionary["hex"] = color.hex
		}

		return dictionary
	}

	public init?(dictionary: JSONDictionary) {
		guard let ID = dictionary["id"] as? String,
			name = dictionary["name"] as? String,
			slug = dictionary["slug"] as? String,
			membersCount = dictionary["members_count"] as? UInt
		else { return nil }

		self.ID = ID
		self.name = name
		self.slug = slug
		self.membersCount = membersCount
		color = (dictionary["color"] as? String).flatMap(Color.init)
	}
}


extension Organization: Hashable {
	public var hashValue: Int {
		return ID.hashValue
	}
}


public func ==(lhs: Organization, rhs: Organization) -> Bool {
	return lhs.ID == rhs.ID
}
