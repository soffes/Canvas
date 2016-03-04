//
//  ChecklistItem.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct ChecklistItem: Listable, NodeContainer {

	// MARK: - Types

	public enum Completion: String {
		case Incomplete = " "
		case Complete = "x"

		public var string: String {
			return rawValue
		}

		public var opposite: Completion {
			switch self {
			case .Incomplete: return .Complete
			case . Complete: return .Incomplete
			}
		}
	}


	// MARK: - Properties

	public var range: NSRange
	public var enclosingRange: NSRange
	public var nativePrefixRange: NSRange
	public var visibleRange: NSRange
	public var indentationRange: NSRange
	public var indentation: Indentation
	public var completedRange: NSRange
	public var completion: Completion
	public var position: Position = .Single

	public var textRange: NSRange {
		return visibleRange
	}

	public var subnodes = [SpanNode]()

	public var dictionary: [String: AnyObject] {
		return [
			"type": "checklist-item",
			"range": range.dictionary,
			"enclosingRange": enclosingRange.dictionary,
			"nativePrefixRange": nativePrefixRange.dictionary,
			"visibleRange": visibleRange.dictionary,
			"indentationRange": indentationRange.dictionary,
			"indentation": indentation.rawValue,
			"position": position.rawValue,
			"subnodes": subnodes.map { $0.dictionary }
		]
	}


	// MARK: - Initializers

	public init?(string: String, range: NSRange, enclosingRange: NSRange) {
		let scanner = NSScanner(string: string)
		scanner.charactersToBeSkipped = nil

		// Delimiter
		if !scanner.scanString("\(leadingNativePrefix)checklist-", intoString: nil) {
			return nil
		}

		var indent = -1
		if !scanner.scanInteger(&indent) {
			return nil
		}

		let indentationRange = NSRange(location:  range.location + scanner.scanLocation, length: 1)
		guard indent != -1, let indentation = Indentation(rawValue: UInt(indent)) else {
			return nil
		}

		self.indentationRange = indentationRange
		self.indentation = indentation

		if !scanner.scanString(trailingNativePrefix, intoString: nil) {
			return nil
		}

		let nativePrefixRange = NSRange(location: range.location, length: scanner.scanLocation)


		// Prefix
		let startPrefix = scanner.scanLocation
		if !scanner.scanString("- [", intoString: nil) {
			return nil
		}

		let set = NSCharacterSet(charactersInString: "x ")
		var completionString: NSString? = ""
		let completedRange = NSRange(location: range.location + scanner.scanLocation, length: 1)
		if !scanner.scanCharactersFromSet(set, intoString: &completionString) {
			return nil
		}

		if let completionString = completionString as? String, completion = Completion(rawValue: completionString) {
			self.completion = completion
		} else {
			return nil
		}

		if !scanner.scanString("] ", intoString: nil) {
			return nil
		}

		let prefixRange = NSRange(location: range.location + startPrefix, length: scanner.scanLocation - startPrefix)
		self.nativePrefixRange = nativePrefixRange.union(prefixRange)

		// Content
		self.completedRange = completedRange
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
		nativePrefixRange.location += delta
		visibleRange.location += delta
		indentationRange.location += delta
		completedRange.location += delta

		subnodes = subnodes.map {
			var node = $0
			node.offset(delta)
			return node
		}
	}


	// MARK: - Native

	public static func nativeRepresentation(indentation indentation: Indentation = .Zero, completion: Completion = .Incomplete) -> String {
		return "\(leadingNativePrefix)checklist-\(indentation.string)\(trailingNativePrefix)- [\(completion.string)] "
	}
}
