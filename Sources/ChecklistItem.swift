//
//  ChecklistItem.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct ChecklistItem: Listable, NodeContainer, Equatable {

	// MARK: - Types

	public enum State: String {
		case Unchecked = " "
		case Checked = "x"

		public var string: String {
			return rawValue
		}

		public var opposite: State {
			switch self {
			case .Unchecked: return .Checked
			case . Checked: return .Unchecked
			}
		}
	}


	// MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange
	public var visibleRange: NSRange
	public var indentationRange: NSRange
	public var indentation: Indentation
	public var stateRange: NSRange
	public var state: State
	public var position: Position = .Single

	public var textRange: NSRange {
		return visibleRange
	}

	public var subnodes = [SpanNode]()

	public var dictionary: [String: AnyObject] {
		return [
			"type": "checklist-item",
			"range": range.dictionary,
			"nativePrefixRange": nativePrefixRange.dictionary,
			"visibleRange": visibleRange.dictionary,
			"indentationRange": indentationRange.dictionary,
			"indentation": indentation.rawValue,
			"stateRange": stateRange.dictionary,
			"state": state.rawValue,
			"position": position.number,
			"subnodes": subnodes.map { $0.dictionary }
		]
	}


	// MARK: - Initializers

	public init?(string: String, range: NSRange) {
		let scanner = NSScanner(string: string)
		scanner.charactersToBeSkipped = nil

		// Delimiter
		if !scanner.scanString("\(leadingNativePrefix)checklist-", intoString: nil) {
			return nil
		}

		var indent = -1
		let indentationLocation = scanner.scanLocation
		if !scanner.scanInteger(&indent) {
			return nil
		}

		let indentationRange = NSRange(location:  range.location + indentationLocation, length: scanner.scanLocation - indentationLocation)
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
		var stateString: NSString? = ""
		let stateRange = NSRange(location: range.location + scanner.scanLocation, length: 1)
		if !scanner.scanCharactersFromSet(set, intoString: &stateString) {
			return nil
		}

		if let stateString = stateString as? String, state = State(rawValue: stateString) {
			self.state = state
		} else {
			return nil
		}

		if !scanner.scanString("] ", intoString: nil) {
			return nil
		}

		let prefixRange = NSRange(location: range.location + startPrefix, length: scanner.scanLocation - startPrefix)
		self.nativePrefixRange = nativePrefixRange.union(prefixRange)

		// Content
		self.stateRange = stateRange
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
		indentationRange.location += delta
		stateRange.location += delta

		subnodes = subnodes.map {
			var node = $0
			node.offset(delta)
			return node
		}
	}


	// MARK: - Native

	public static func nativeRepresentation(indentation indentation: Indentation = .Zero, state: State = .Unchecked) -> String {
		return "\(leadingNativePrefix)checklist-\(indentation.string)\(trailingNativePrefix)- [\(state.string)] "
	}
}


public func ==(lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
	return NSEqualRanges(lhs.range, rhs.range) &&
		NSEqualRanges(lhs.nativePrefixRange, rhs.nativePrefixRange) &&
		NSEqualRanges(lhs.visibleRange, rhs.visibleRange) &&
		NSEqualRanges(lhs.indentationRange, rhs.indentationRange) &&
		lhs.indentation == rhs.indentation &&
		NSEqualRanges(lhs.stateRange, rhs.stateRange) &&
		lhs.state == rhs.state &&
		lhs.position == rhs.position
}
