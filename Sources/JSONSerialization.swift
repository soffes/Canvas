//
//  JSONSerialization.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/3/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public typealias JSONDictionary = [String: AnyObject]

public protocol JSONSerializable {
	var dictionary: JSONDictionary { get }
}

public protocol JSONDeserializable {
	init?(dictionary: JSONDictionary)
}
