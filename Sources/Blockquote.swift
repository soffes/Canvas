//
//  Blockquote.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Blockquote: BlockNode, NativePrefixable, Positionable, NodeContainer, ReturnCompletable {

	// MARK: - Properties

	public var range: NSRange
	public var enclosingRange: NSRange
	public var nativePrefixRange: NSRange
	public var visibleRange: NSRange
	public var position: Position = .Single

	public var textRange: NSRange {
		return visibleRange
	}

	public var subnodes = [SpanNode]()

	public var dictionary: [String: AnyObject] {
		return [
			"type": "blockquote",
			"range": range.dictionary,
			"enclosingRange": enclosingRange.dictionary,
			"nativePrefixRange": nativePrefixRange.dictionary,
			"visibleRange": visibleRange.dictionary,
			"position": position.rawValue,
			"subnodes": subnodes.map { $0.dictionary }
		]
	}


	// MARK: - Initializers

	public init?(string: String, range: NSRange, enclosingRange: NSRange) {
		guard let (nativePrefixRange, prefixRange, visibleRange) = parseBlockNode(
			string: string,
			range: range,
			delimiter: "blockquote",
			prefix: "> "
		) else { return nil }

		self.range = range
		self.enclosingRange = enclosingRange
		self.nativePrefixRange = nativePrefixRange.union(prefixRange)
		self.visibleRange = visibleRange
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		range.location += delta
		enclosingRange.location += delta
		nativePrefixRange.location += delta
		visibleRange.location += delta

		subnodes = subnodes.map {
			var node = $0
			node.offset(delta)
			return node
		}
	}


	// MARK: - Native

	public static func nativeRepresentation() -> String {
		return "\(leadingNativePrefix)blockquote\(trailingNativePrefix)> "
	}
}
