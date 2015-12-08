//
//  Collection.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/3/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

public struct Collection {

	// MARK: - Properties

	public let ID: String
	public let name: String
}


extension Collection: JSONSerializable, JSONDeserializable {
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


extension Collection: Hashable {
	public var hashValue: Int {
		return ID.hashValue
	}
}


public func ==(lhs: Collection, rhs: Collection) -> Bool {
	return lhs.ID == rhs.ID
}
