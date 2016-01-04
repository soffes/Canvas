//
//  Organization.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/3/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

public struct Organization: Model {

	// MARK: - Properties

	public let ID: String
	public let name: String

	public var displayName: String {
		return name.capitalizedString
	}
}


extension Organization: JSONSerializable, JSONDeserializable {
	public var dictionary: JSONDictionary {
		return [
			"id": ID,
			"name": name
		]
	}

	public init?(dictionary: JSONDictionary) {
		guard let ID = dictionary["id"] as? String,
			name = dictionary["name"] as? String
		else { return nil }

		self.ID = ID
		self.name = name
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
