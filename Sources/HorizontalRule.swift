//
//  HorizontalRule.swift
//  CanvasNative
//
//  Created by Sam Soffes on 4/19/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

private let regularExpression = try! NSRegularExpression(pattern: "^(?:\\s{0,2}(?:(\\s?\\*\\s*?){3,})|(?:(\\s?-\\s*?){3,})|(?:(\\s?_\\s*?){3,})[ \\t]*)$", options: [])

public struct HorizontalRule: Attachable, Equatable {

	// MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange

	public var dictionary: [String: AnyObject] {
		return [
			"type": "horizontal-rule",
			"range": range.dictionary,
			"nativePrefixRange": nativePrefixRange.dictionary,
		]
	}

	public var hiddenRanges: [NSRange] {
		return [nativePrefixRange]
	}


	// MARK: - Initializers

	public init?(string: String, range: NSRange) {
		if string != HorizontalRule.nativeRepresentation() {
			return nil
		}

		self.range = range
		nativePrefixRange = NSRange(location: range.location, length: range.length - 1)
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		range.location += delta
		nativePrefixRange.location += delta
	}


	// MARK: - Native

	public static func nativeRepresentation() -> String {
		return "\(leadingNativePrefix)horizontal-rule\(trailingNativePrefix)"
	}
}


public func == (lhs: HorizontalRule, rhs: HorizontalRule) -> Bool {
	return NSEqualRanges(lhs.range, rhs.range) &&
		NSEqualRanges(lhs.nativePrefixRange, rhs.nativePrefixRange)
}
