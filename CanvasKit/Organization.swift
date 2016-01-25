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
	public let color: Color
}


extension Organization: JSONSerializable, JSONDeserializable {
	public var dictionary: JSONDictionary {
		return [
			"id": ID,
			"name": name,
			"slug": slug,
			"members_count": membersCount,
			"color": color.hex
		]
	}

	public init?(dictionary: JSONDictionary) {
		guard let ID = dictionary["id"] as? String,
			name = dictionary["name"] as? String,
			slug = dictionary["slug"] as? String,
			membersCount = dictionary["members_count"] as? UInt,
			colorHex = dictionary["color"] as? String,
			color = Color(hex: colorHex)
		else { return nil }

		print("\(name): \(colorHex)")

		self.ID = ID
		self.name = name
		self.slug = slug
		self.membersCount = membersCount
		self.color = color
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
