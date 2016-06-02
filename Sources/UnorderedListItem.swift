//
//  UnorderedListItem.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct UnorderedListItem: Listable, NodeContainer, Equatable {

	// MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange
	public var visibleRange: NSRange
	public var indentationRange: NSRange
	public var indentation: Indentation
	public var position: Position = .Single

	public var textRange: NSRange {
		return visibleRange
	}

	public var subnodes = [SpanNode]()

	public var dictionary: [String: AnyObject] {
		return [
			"type": "unordered-list",
			"range": range.dictionary,
			"nativePrefixRange": nativePrefixRange.dictionary,
			"visibleRange": visibleRange.dictionary,
			"indentationRange": indentationRange.dictionary,
			"indentation": indentation.rawValue,
			"position": position.description,
			"subnodes": subnodes.map { $0.dictionary }
		]
	}


	// MARK: - Initializers

	public init?(string: String, range: NSRange) {
		guard let (nativePrefixRange, indentationRange, indentation, prefixRange, visibleRange) = parseListable(
			string: string,
			range: range,
			delimiter: "unordered-list",
			prefix: "- "
		) else { return nil }

		self.range = range
		self.nativePrefixRange = nativePrefixRange.union(prefixRange)
		self.visibleRange = visibleRange
		self.indentationRange = indentationRange
		self.indentation = indentation
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		range.location += delta
		nativePrefixRange.location += delta
		visibleRange.location += delta
		indentationRange.location += delta
		
		subnodes = subnodes.map {
			var node = $0
			node.offset(delta)
			return node
		}
	}


	// MARK: - Native

	public static func nativeRepresentation(indentation indentation: Indentation = .Zero) -> String {
		return "\(leadingNativePrefix)unordered-list-\(indentation.string)\(trailingNativePrefix)- "
	}
}


public func ==(lhs: UnorderedListItem, rhs: UnorderedListItem) -> Bool {
	return NSEqualRanges(lhs.range, rhs.range) &&
		NSEqualRanges(lhs.nativePrefixRange, rhs.nativePrefixRange) &&
		NSEqualRanges(lhs.visibleRange, rhs.visibleRange) &&
		NSEqualRanges(lhs.indentationRange, rhs.indentationRange) &&
		lhs.indentation == rhs.indentation &&
		lhs.position == rhs.position
}
