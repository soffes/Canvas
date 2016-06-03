//
//  InlineMarker.swift
//  CanvasNative
//
//  Created by Sam Soffes on 6/1/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct InlineMarker: Node {

	// MARK: - Types

	public enum Position: Int {
		case Opening
		case Closing
	}


	// MARK: - Properties

	public var range: NSRange
	
	public var visibleRange: NSRange {
		return NSRange(location: range.location, length: 0)
	}

	public var dictionary: [String: AnyObject] {
		return [
			"type": "inline-marker",
			"range": range.dictionary,
			"position": position.rawValue,
			"id": id
		]
	}

	public var position: Position
	public var id: String


	// MARK: - Initializers

	public init(range: NSRange, position: Position, id: String) {
		self.range = range
		self.position = position
		self.id = id
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		range.location += delta
	}
}
