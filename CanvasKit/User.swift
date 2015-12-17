//
//  User.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/11/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct User: Model {
	
	// MARK: - Properties
	
	public let ID: String
	public let username: String
	public let avatarURL: NSURL?
}


extension User: JSONSerializable, JSONDeserializable {
	public var dictionary: JSONDictionary {
		var dictionary = [
			"id": ID,
			"username": username,
		]

		if let avatarURL = avatarURL {
			dictionary["avatar_url"] = avatarURL.absoluteString
		}

		return dictionary
	}
	
	public init?(dictionary: JSONDictionary) {
		guard let ID = dictionary["id"] as? String,
			username = dictionary["username"] as? String
		else { return nil }
		
		self.ID = ID
		self.username = username
		avatarURL = (dictionary["avatar_url"] as? String).flatMap { NSURL(string: $0) }
	}
}


extension User: Hashable {
	public var hashValue: Int {
		return ID.hashValue
	}
}


public func ==(lhs: User, rhs: User) -> Bool {
	return lhs.ID == rhs.ID
}
