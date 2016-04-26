//
//  OrderedListItem.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct OrderedListItem: Listable, NodeContainer, Equatable {

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
			"type": "ordered-list",
			"range": range.dictionary,
			"nativePrefixRange": nativePrefixRange.dictionary,
			"visibleRange": visibleRange.dictionary,
			"indentationRange": indentationRange.dictionary,
			"indentation": indentation.rawValue,
			"position": position.number,
			"subnodes": subnodes.map { $0.dictionary }
		]
	}


	// MARK: - Initializers

	public init?(string: String, range: NSRange) {
		guard let (nativePrefixRange, indentationRange, indentation, prefixRange, visibleRange) = parseListable(
			string: string,
			range: range,
			delimiter: "ordered-list",
			prefix: "1. "
		)else { return nil }

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
		return "\(leadingNativePrefix)ordered-list-\(indentation.string)\(trailingNativePrefix)1. "
	}
}


public func ==(lhs: OrderedListItem, rhs: OrderedListItem) -> Bool {
	return NSEqualRanges(lhs.range, rhs.range) &&
		NSEqualRanges(lhs.nativePrefixRange, rhs.nativePrefixRange) &&
		NSEqualRanges(lhs.visibleRange, rhs.visibleRange) &&
		NSEqualRanges(lhs.indentationRange, rhs.indentationRange) &&
		lhs.indentation == rhs.indentation &&
		lhs.position == rhs.position
}
