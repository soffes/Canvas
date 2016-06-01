//
//  InlineMarker.swift
//  CanvasNative
//
//  Created by Sam Soffes on 6/1/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct InlineMarker: Node {

	// MARK: - Constants

	static let leadingDelimiter = "☊"
	static let closingMarker = "Ω"
	static let trailingDelimiter = "☋"


	// MARK: - Types

	public enum Kind: String {
		case Comment = "co"
		case Unknown = "??"
	}

	public enum Position: Int {
		case Opening
		case Closing
	}


	// MARK: - Properties

	public var range: NSRange
	
	public var visibleRange: NSRange {
		return NSRange(location: range.location, length: 0)
	}

	public var dictionary: [String: AnyObject] {
		return [
			"type": "inline-marker",
			"range": range.dictionary,
			"kind": kind.rawValue,
			"position": position.rawValue,
			"id": id
		]
	}

	public var kind: Kind
	public var position: Position
	public var id: String


	// MARK: - Initializers

//	public init?(string: String) {
//		let scanner = NSScanner(string: string)
//		scanner.charactersToBeSkipped = nil
//
//		// Leading delimiter
//		if !scanner.scanString(InlineMarker.leadingDelimiter, intoString: nil) {
//			return nil
//		}
//
//		// Position
//		position = scanner.scanString(InlineMarker.closingMarker, intoString: nil) ? .Closing : .Opening
//
//		// Kind
//		var scannedKind: NSString? = ""
//		scanner.scanUpToString("|", intoString: &scannedKind)
//
//		guard let kind = scannedKind as? String else { return nil }
//		self.kind = Kind(rawValue: kind) ?? .Unknown
//
//		if !scanner.scanString("|", intoString: nil) {
//			return nil
//		}
//
//		// ID
//		var scannedID: NSString? = ""
//		scanner.scanUpToString(InlineMarker.trailingDelimiter, intoString: &scannedID)
//
//		guard let id = scannedID as? String else { return nil }
//		self.id = id
//
//		// Trailing marker
//		if !scanner.scanString(InlineMarker.trailingDelimiter, intoString: nil) {
//			return nil
//		}
//	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		range.location += delta
	}
}
