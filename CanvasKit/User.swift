//
//  User.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/11/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

public struct User: Model {
	
	// MARK: - Properties
	
	public let ID: String
	public let username: String
	public let email: String
}


extension User: JSONSerializable, JSONDeserializable {
	public var dictionary: JSONDictionary {
		return [
			"id": ID,
			"username": username,
			"email": email
		]
	}
	
	public init?(dictionary: JSONDictionary) {
		guard let ID = dictionary["id"] as? String,
			username = dictionary["username"] as? String,
			email = dictionary["email"] as? String
		else { return nil }
		
		self.ID = ID
		self.username = username
		self.email = email
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
