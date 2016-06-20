//
//  Heading.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Heading: BlockNode, NodeContainer, Foldable, InlineMarkerContainer, Equatable {

	// MARK: - Types

	public enum Level: UInt {
		case one = 1
		case two = 2
		case three = 3
		case four = 4
		case five = 5
		case six = 6

		public var successor: Level {
			if self == .six {
				return self
			}

			return Level(rawValue: rawValue + 1)!
		}

		public var predecessor: Level {
			if self == .one {
				return self
			}

			return Level(rawValue: rawValue - 1)!
		}

		public var isMinimum: Bool {
			return self == .one
		}

		public var isMaximum: Bool {
			return self == .six
		}

		public var string: String {
			return rawValue.description
		}
	}


	// MARK: - Properties

	public var range: NSRange
	public var visibleRange: NSRange
	public var leadingDelimiterRange: NSRange
	public var textRange: NSRange
	public var level: Level

	public var foldableRanges: [NSRange] {
		return [leadingDelimiterRange]
	}

	public var subnodes = [SpanNode]()
	public var inlineMarkerPairs = [InlineMarkerPair]()

	public var dictionary: [String: AnyObject] {
		return [
			"type": "heading",
			"range": range.dictionary,
			"visibleRange": visibleRange.dictionary,
			"leadingDelimiterRange": leadingDelimiterRange.dictionary,
			"textRange": textRange.dictionary,
			"level": level.rawValue,
			"subnodes": subnodes.map { $0.dictionary },
			"inlineMarkerPairs": inlineMarkerPairs.map { $0.dictionary }
		]
	}


	// MARK: - Initializers

	public init?(string: String, range: NSRange) {
		let scanner = NSScanner(string: string)
		scanner.charactersToBeSkipped = nil

		// Prefix
		var hashes: NSString? = ""
		if !scanner.scanCharactersFromSet(NSCharacterSet(charactersInString: "#"), intoString: &hashes) {
			return nil
		}

		guard let count = hashes?.length, level = Level(rawValue: UInt(count)) else { return nil }
		self.level = level

		if !scanner.scanString(" ", intoString: nil) {
			return nil
		}

		leadingDelimiterRange = NSRange(location: range.location, length: scanner.scanLocation)

		// Content
		textRange = NSRange(
			location: range.location + scanner.scanLocation,
			length: range.length - scanner.scanLocation
		)

		self.range = range
		visibleRange = range
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		range.location += delta
		visibleRange.location += delta
		leadingDelimiterRange.location += delta
		textRange.location += delta

		subnodes = subnodes.map {
			var node = $0
			node.offset(delta)
			return node
		}

		inlineMarkerPairs = inlineMarkerPairs.map {
			var pair = $0
			pair.offset(delta)
			return pair
		}
	}


	// MARK: - Native

	public static func nativeRepresentation(level level: Level = .one) -> String {
		var prefix = ""

		for _ in 0..<level.rawValue {
			prefix += "#"
		}

		prefix += " "

		return prefix
	}
}


public func ==(lhs: Heading, rhs: Heading) -> Bool {
	return NSEqualRanges(lhs.range, rhs.range) &&
		NSEqualRanges(lhs.visibleRange, rhs.visibleRange) &&
		NSEqualRanges(lhs.leadingDelimiterRange, rhs.leadingDelimiterRange) &&
		NSEqualRanges(lhs.textRange, rhs.textRange) &&
		lhs.level == rhs.level
}
