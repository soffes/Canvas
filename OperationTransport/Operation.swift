//
//  Operation.swift
//  OperationTransport
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public enum Operation {
	
	// MARK: - Cases
	
	case Insert(location: UInt, string: String)
	case Remove(location: UInt, length: UInt)
	
	
	// MARK: - Properties
	
	public var range: NSRange {
		switch self {
		case .Insert(let location, _):
			return NSRange(location: Int(location), length: 0)
		case .Remove(let location, let length):
			return NSRange(location: Int(location), length: Int(length))
		}
	}
	
	
	// MARK: - Initializers
	
	public init?(dictionary: [String: AnyObject]) {
		guard let type = dictionary["type"] as? String,
			location = dictionary["location"] as? UInt
			else { return nil }
		
		if let string = dictionary["text"] as? String where type == "insert" {
			self = .Insert(location: location, string: string)
			return
		}
		
		if let length = dictionary["length"] as? UInt where type == "remove" {
			self = .Remove(location: location, length: length)
			return
		}
		
		return nil
	}
}
