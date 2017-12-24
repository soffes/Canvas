//
//  CodeSpan.swift
//  CanvasNative
//
//  Created by Sam Soffes on 1/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct CodeSpan: SpanNode, Foldable {

	// MARK: - Properties

	public var leadingDelimiterRange: NSRange
	public var textRange: NSRange
	public var trailingDelimiterRange: NSRange

	public var range: NSRange {
		return leadingDelimiterRange.union(textRange).union(trailingDelimiterRange)
	}

	public var visibleRange: NSRange {
		return range
	}

	public var foldableRanges: [NSRange] {
		return [
			leadingDelimiterRange,
			trailingDelimiterRange
		]
	}

	public var dictionary: [String: AnyObject] {
		return [
			"type": "code-span",
			"range": range.dictionary,
			"visibleRange": visibleRange.dictionary,
			"leadingDelimiterRange": leadingDelimiterRange.dictionary,
			"textRange": textRange.dictionary,
			"trailingDelimiterRange": trailingDelimiterRange.dictionary,
		]
	}


	// MARK: - Initializers

	public init(leadingDelimiterRange: NSRange, textRange: NSRange, trailingDelimiterRange: NSRange, subnodes: [SpanNode] = []) {
		self.leadingDelimiterRange = leadingDelimiterRange
		self.textRange = textRange
		self.trailingDelimiterRange = trailingDelimiterRange
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		leadingDelimiterRange.location += delta
		textRange.location += delta
		trailingDelimiterRange.location += delta
	}
}


extension CodeSpan: SpanNodeParseable {
	static let regularExpression: NSRegularExpression! = try? NSRegularExpression(pattern: "(`+)(.+?)(?<!`)(\\1)(?!`)", options: [])

	init?(match: NSTextCheckingResult) {
		if match.numberOfRanges != 4 {
			return nil
		}

		leadingDelimiterRange = match.rangeAtIndex(1)
		textRange = match.rangeAtIndex(2)
		trailingDelimiterRange = match.rangeAtIndex(3)
	}
}
