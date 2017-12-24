//
//  Operation.swift
//  OperationalTransformation
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public enum Operation {
	
	// MARK: - Cases
	
	case insert(location: UInt, string: String)
	case remove(location: UInt, length: UInt)
	
	
	// MARK: - Properties
	
	public var range: NSRange {
		switch self {
		case .insert(let location, _):
			return NSRange(location: Int(location), length: 0)
		case .remove(let location, let length):
			return NSRange(location: Int(location), length: Int(length))
		}
	}
	
	
	// MARK: - Initializers
	
	public init?(dictionary: [String: AnyObject]) {
		guard let type = dictionary["type"] as? String,
			location = dictionary["location"] as? UInt
			else { return nil }
		
		if let string = dictionary["text"] as? String where type == "insert" {
			self = .insert(location: location, string: string)
			return
		}
		
		if let length = dictionary["length"] as? UInt where type == "remove" {
			self = .remove(location: location, length: length)
			return
		}
		
		return nil
	}
}
