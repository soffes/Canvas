//
//  CodeBlock.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct CodeBlock: ReturnCompletable, NativePrefixable, Positionable, Equatable {

	// MARK: - Properties

	public var range: NSRange
	public var enclosingRange: NSRange
	public var nativePrefixRange: NSRange
	public var visibleRange: NSRange
	public var position: Position = .Single
	public var language: String?

	public var dictionary: [String: AnyObject] {
		var dictionary: [String: AnyObject] = [
			"type": "code-block",
			"range": range.dictionary,
			"enclosingRange": enclosingRange.dictionary,
			"nativePrefixRange": nativePrefixRange.dictionary,
			"visibleRange": visibleRange.dictionary,
			"position": position.number
		]

		if let language = language {
			dictionary["language"] = language
		}

		return dictionary
	}


	// MARK: - Initializers

	public init?(string: String, range: NSRange, enclosingRange: NSRange) {
		let scanner = NSScanner(string: string)
		scanner.charactersToBeSkipped = nil

		// Delimiter
		if !scanner.scanString("\(leadingNativePrefix)code", intoString: nil) {
			return nil
		}

		// Language
		let scanLocation = scanner.scanLocation
		var language: NSString? = ""
		if scanner.scanString("-", intoString: nil) && scanner.scanUpToString(trailingNativePrefix, intoString: &language), let language = language as? String {
			self.language = language
		} else {
			self.language = nil
			scanner.scanLocation = scanLocation
		}

		// Closing delimiter
		guard scanner.scanString(trailingNativePrefix, intoString: nil) else {
			return nil
		}

		nativePrefixRange = NSRange(location: range.location, length: scanner.scanLocation)

		// Content
		visibleRange = NSRange(
			location: range.location + scanner.scanLocation,
			length: range.length - scanner.scanLocation
		)

		self.range = range
		self.enclosingRange = enclosingRange
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		range.location += delta
		enclosingRange.location += delta
		nativePrefixRange.location += delta
		visibleRange.location += delta
	}


	// MARK: - Native

	public static func nativeRepresentation(language language: String? = nil) -> String {
		let lang = language.flatMap { "-\($0)" } ?? ""
		return "\(leadingNativePrefix)code\(lang)\(trailingNativePrefix)"
	}
}


public func ==(lhs: CodeBlock, rhs: CodeBlock) -> Bool {
	return NSEqualRanges(lhs.range, rhs.range) &&
		NSEqualRanges(lhs.enclosingRange, rhs.enclosingRange) &&
		NSEqualRanges(lhs.nativePrefixRange, rhs.nativePrefixRange) &&
		NSEqualRanges(lhs.visibleRange, rhs.visibleRange) &&
		lhs.language == rhs.language &&
		lhs.position == rhs.position
}
