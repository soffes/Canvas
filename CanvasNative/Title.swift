//
//  Title.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Title: NativePrefixable {

	// MARK: - Properties

	public var range: NSRange
	public var enclosingRange: NSRange
	public var nativePrefixRange: NSRange
	public var displayRange: NSRange

	public var dictionary: [String: AnyObject] {
		return [
			"type": "title",
			"range": range.dictionary,
			"enclosingRange": enclosingRange.dictionary,
			"nativePrefixRange": nativePrefixRange.dictionary,
			"displayRange": displayRange.dictionary
		]
	}


	// MARK: - Initializers

	public init?(string: String, range: NSRange, enclosingRange: NSRange) {
		guard let (nativePrefixRange, displayRange) = parseBlockNode(
			string: string,
			range: range,
			delimiter: "doc-heading"
		) else { return nil }

		self.range = range
		self.enclosingRange = enclosingRange
		self.nativePrefixRange = nativePrefixRange
		self.displayRange = displayRange
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		range.location += delta
		enclosingRange.location += delta
		nativePrefixRange.location += delta
		displayRange.location += delta
	}


	// MARK: - Native

	public static func nativeRepresentation(string: String? = nil) -> String {
		return "\(leadingNativePrefix)doc-heading\(trailingNativePrefix)" + (string ?? "")
	}
}
