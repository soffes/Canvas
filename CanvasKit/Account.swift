//
//  Account.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/3/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

public struct Account {

	// MARK: - Properties

	public let accessToken: String
	public let user: User
	
	
	// MARK: - Initializers
	
	public init(accessToken: String, user: User) {
		self.accessToken = accessToken
		self.user = user
	}
}


extension Account: JSONSerializable, JSONDeserializable {
	public var dictionary: JSONDictionary {
		return [
			"access_token": accessToken,
			"user": user.dictionary
		]
	}

	public init?(dictionary: JSONDictionary) {
		guard let accessToken = dictionary["access_token"] as? String,
			userDictionary = dictionary["user"] as? JSONDictionary,
			user = User(dictionary: userDictionary)
		else { return nil }
		
		self.accessToken = accessToken
		self.user = user
	}
}

