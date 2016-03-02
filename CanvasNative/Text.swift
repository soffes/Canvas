//
//  Text.swift
//  CanvasNative
//
//  Created by Sam Soffes on 1/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Text: SpanNode {

	// MARK: - Properties

	public var range: NSRange

	public var visibleRange: NSRange {
		return range
	}

	public var dictionary: [String: AnyObject] {
		return [
			"type": "text",
			"range": range.dictionary,
			"visibleRange": visibleRange.dictionary
		]
	}


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		range = enclosingRange
	}

	public init(range: NSRange) {
		self.range = range
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		range.location += delta
	}
}
