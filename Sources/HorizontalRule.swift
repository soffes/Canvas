//
//  HorizontalRule.swift
//  CanvasNative
//
//  Created by Sam Soffes on 4/19/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

private let regularExpressions = [
	try! NSRegularExpression(pattern: "^\\s{0,2}(\\s?\\-\\s*?){3,}[ \\t]*$", options: []),
	try! NSRegularExpression(pattern: "^\\s{0,2}(\\s?\\*\\s*?){3,}[ \\t]*$", options: []),
	try! NSRegularExpression(pattern: "^\\s{0,2}(\\s?_\\s*?){3,}[ \\t]*$", options: [])
]

public struct HorizontalRule: Attachable, Equatable {

	// MARK: - Properties

	public var range: NSRange
	public var enclosingRange: NSRange
	public var nativePrefixRange: NSRange

	public var dictionary: [String: AnyObject] {
		return [
			"type": "horizontal-rule",
			"range": range.dictionary,
			"enclosingRange": enclosingRange.dictionary,
			"nativePrefixRange": nativePrefixRange.dictionary,
		]
	}


	// MARK: - Initializers

	public init?(string: String, range: NSRange, enclosingRange: NSRange) {
		for regularExpression in regularExpressions {
			if let match = regularExpression.firstMatchInString(string, options: [], range: range) where NSEqualRanges(match.range, range) {
				self.range = range
				self.enclosingRange = enclosingRange
				nativePrefixRange = NSRange(location: range.location, length: range.length - 1)
				return
			}
		}

		return nil
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		range.location += delta
		enclosingRange.location += delta
		nativePrefixRange.location += delta
	}


	// MARK: - Native

	public static func nativeRepresentation() -> String {
		return "---"
	}
}


public func == (lhs: HorizontalRule, rhs: HorizontalRule) -> Bool {
	return NSEqualRanges(lhs.range, rhs.range) &&
		NSEqualRanges(lhs.enclosingRange, rhs.enclosingRange) &&
		NSEqualRanges(lhs.nativePrefixRange, rhs.nativePrefixRange)
}
