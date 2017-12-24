//
//  User.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/11/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct User {
	
	// MARK: - Properties
	
	public let id: String
	public let username: String?
	public let avatarURL: NSURL?
}


extension User: JSONSerializable, JSONDeserializable {
	public var dictionary: JSONDictionary {
		var dictionary = [
			"id": id
		]
		
		if let username = username {
			dictionary["username"] = username
		}

		if let avatarURL = avatarURL {
			dictionary["avatar_url"] = avatarURL.absoluteString
		}

		return dictionary
	}
	
	public init?(dictionary: JSONDictionary) {
		guard let id = dictionary["id"] as? String else { return nil }
		
		self.id = id
		username = dictionary["username"] as? String
		avatarURL = (dictionary["avatar_url"] as? String).flatMap { NSURL(string: $0) }
	}
}


extension User: Hashable {
	public var hashValue: Int {
		return id.hashValue
	}
}


public func ==(lhs: User, rhs: User) -> Bool {
	return lhs.id == rhs.id
}
