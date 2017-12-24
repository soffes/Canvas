//
//  CodeBlock.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct CodeBlock: ReturnCompletable, NativePrefixable, Positionable, InlineMarkerContainer, Equatable {

	// MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange
	public var visibleRange: NSRange
	public var position: Position = .single
	public var language: String?

	public var inlineMarkerPairs = [InlineMarkerPair]()

	public var dictionary: [String: AnyObject] {
		var dictionary: [String: AnyObject] = [
			"type": "code-block",
			"range": range.dictionary,
			"nativePrefixRange": nativePrefixRange.dictionary,
			"visibleRange": visibleRange.dictionary,
			"position": position.description,
			"lineNumber": lineNumber,
			"inlineMarkerPairs": inlineMarkerPairs.map { $0.dictionary }
		]

		if let language = language {
			dictionary["language"] = language
		}

		return dictionary
	}

	public var lineNumber: UInt = 0
	

	// MARK: - Initializers

	public init?(string: String, range: NSRange) {
		let scanner = NSScanner(string: string)
		scanner.charactersToBeSkipped = nil

		// Delimiter
		if !scanner.scanString("\(leadingNativePrefix)code", intoString: nil) {
			return nil
		}

		// Language
		var language: NSString? = ""
		if scanner.scanString("-", intoString: nil) {
			let scanLocation = scanner.scanLocation
			if scanner.scanUpToString(trailingNativePrefix, intoString: &language), let language = language as? String {
				self.language = language
			} else {
				self.language = nil
				scanner.scanLocation = scanLocation
			}
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
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		range.location += delta
		nativePrefixRange.location += delta
		visibleRange.location += delta

		inlineMarkerPairs = inlineMarkerPairs.map {
			var pair = $0
			pair.offset(delta)
			return pair
		}
	}


	// MARK: - Native

	public static func nativeRepresentation(language language: String? = nil) -> String {
		let lang = language.flatMap { "-\($0)" } ?? ""
		return "\(leadingNativePrefix)code\(lang)\(trailingNativePrefix)"
	}
}


public func ==(lhs: CodeBlock, rhs: CodeBlock) -> Bool {
	return NSEqualRanges(lhs.range, rhs.range) &&
		NSEqualRanges(lhs.nativePrefixRange, rhs.nativePrefixRange) &&
		NSEqualRanges(lhs.visibleRange, rhs.visibleRange) &&
		lhs.language == rhs.language &&
		lhs.position == rhs.position
}
