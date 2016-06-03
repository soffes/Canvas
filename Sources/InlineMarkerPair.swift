//
//  InlineMarkerPair.swift
//  CanvasNative
//
//  Created by Sam Soffes on 6/3/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct InlineMarkerPair: Node {

	// MARK: - Properties

	static let regularExpression: NSRegularExpression! = try? NSRegularExpression(pattern: "(☊([a-z]{2})\\|([a-zA-Z0-9]{22})☋)(.*)(☊Ω\\2\\|\\3☋)", options: [])

	public var range: NSRange {
		return openingMarker.range.union(closingMarker.range)
	}

	public var visibleRange: NSRange {
		let location = openingMarker.range.max
		return NSRange(location: location, length: closingMarker.range.location - location)
	}

	public var dictionary: [String: AnyObject] {
		return [
			"type": "inline-marker-pair",
			"openingMarker": openingMarker.dictionary,
			"closingMarker": closingMarker.dictionary
		]
	}

	public var openingMarker: InlineMarker
	public var closingMarker: InlineMarker


	// MARK: - Initializers

	public init(openingMarker: InlineMarker, closingMarker: InlineMarker) {
		self.openingMarker = openingMarker
		self.closingMarker = closingMarker
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		openingMarker.offset(delta)
		closingMarker.offset(delta)
	}
}
