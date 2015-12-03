//
//  SearchCredential.swift
//  CanvasKit
//
//  Created by Sam Soffes on 12/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

public struct SearchCredential {

	// MARK: - Properties

	public let applicationID: String
	public let searchKey: String
}


extension SearchCredential: JSONSerializable, JSONDeserializable {
	public var dictionary: JSONDictionary {
		return [
			"application_id": applicationID,
			"search_key": searchKey
		]
	}

	public init?(dictionary: JSONDictionary) {
		guard let applicationID = dictionary["application_id"] as? String,
			searchKey = dictionary["search_key"] as? String
		else { return nil }

		self.applicationID = applicationID
		self.searchKey = searchKey
	}
}
