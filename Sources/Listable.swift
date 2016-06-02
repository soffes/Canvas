//
//  Listable.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public enum Indentation: UInt {
	case Zero = 0
	case One = 1
	case Two = 2
	case Three = 3

	public var successor: Indentation {
		if isMaximum {
			return self
		}

		return Indentation(rawValue: rawValue + 1)!
	}

	public var predecessor: Indentation {
		if isMinimum {
			return self
		}

		return Indentation(rawValue: rawValue - 1)!
	}

	public var isMinimum: Bool {
		return self == .Zero
	}

	public var isMaximum: Bool {
		return self == .Three
	}

	public var string: String {
		return rawValue.description
	}
}

extension Indentation: Comparable {}

@warn_unused_result public func <(lhs: Indentation, rhs: Indentation) -> Bool {
	return lhs.rawValue < rhs.rawValue
}

@warn_unused_result public func <=(lhs: Indentation, rhs: Indentation) -> Bool {
	return lhs.rawValue <= rhs.rawValue
}

@warn_unused_result public func >=(lhs: Indentation, rhs: Indentation) -> Bool {
	return lhs.rawValue >= rhs.rawValue
}

@warn_unused_result public func >(lhs: Indentation, rhs: Indentation) -> Bool {
	return lhs.rawValue > rhs.rawValue
}


public protocol Listable: ReturnCompletable, NativePrefixable, Positionable {
	var indentation: Indentation { get }
	var indentationRange: NSRange { get }
}


func parseListable(string string: String, range: NSRange, delimiter: String, prefix: String) -> (nativePrefixRange: NSRange, indentationRange: NSRange, indentation: Indentation, prefixRange: NSRange, visibleRange: NSRange)? {
	let scanner = NSScanner(string: string)
	scanner.charactersToBeSkipped = nil

	// Delimiter
	if !scanner.scanString(leadingNativePrefix, intoString: nil) {
		return nil
	}

	if !scanner.scanString("\(delimiter)-", intoString: nil) {
		return nil
	}

	let indentationRange = NSRange(location:  range.location + scanner.scanLocation, length: 1)
	var indent = -1
	if !scanner.scanInteger(&indent) {
		return nil
	}

	guard indent != -1, let indentation = Indentation(rawValue: UInt(indent)) else {
		return nil
	}

	if !scanner.scanString(trailingNativePrefix, intoString: nil) {
		return nil
	}

	let nativePrefixRange = NSRange(location: range.location, length: scanner.scanLocation)

	// Prefix
	let startPrefix = scanner.scanLocation
	if !scanner.scanString(prefix, intoString: nil) {
		return nil
	}

	let prefixRange = NSRange(location: range.location + startPrefix, length: scanner.scanLocation - startPrefix)

	// Content
	let visibleRange = NSRange(
		location: range.location + scanner.scanLocation,
		length: range.length - scanner.scanLocation
	)

	return (nativePrefixRange, indentationRange, indentation, prefixRange, visibleRange)
}
