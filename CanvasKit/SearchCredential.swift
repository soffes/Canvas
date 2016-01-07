//
//  SearchCredential.swift
//  CanvasKit
//
//  Created by Sam Soffes on 12/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import ISO8601

public struct SearchCredential {

	// MARK: - Properties

	public let applicationID: String
	public let key: String
	public let index: String
	public let expiresAt: NSDate
}


extension SearchCredential: JSONSerializable, JSONDeserializable {
	public var dictionary: JSONDictionary {
		guard let expiresAtString = expiresAt.ISO8601String() else { return [:] }
		return [
			"application_id": applicationID,
			"key": key,
			"index": index,
			"expires_at": expiresAtString
		]
	}

	public init?(dictionary: JSONDictionary) {
		guard let applicationID = dictionary["application_id"] as? String,
			key = dictionary["key"] as? String,
			index = dictionary["index"] as? String,
			expiresAtString = dictionary["expires_at"] as? String,
			expiresAt = NSDate(ISO8601String: expiresAtString)
		else { return nil }

		self.applicationID = applicationID
		self.key = key
		self.index = index
		self.expiresAt = expiresAt
	}
}
