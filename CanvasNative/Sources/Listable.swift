import Foundation

public enum Indentation: UInt {
	case zero = 0
	case one = 1
	case two = 2
	case three = 3

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
		return self == .zero
	}

	public var isMaximum: Bool {
		return self == .three
	}

	public var string: String {
		return rawValue.description
	}
}

extension Indentation: Comparable {}

public func <(lhs: Indentation, rhs: Indentation) -> Bool {
	return lhs.rawValue < rhs.rawValue
}

public func <=(lhs: Indentation, rhs: Indentation) -> Bool {
	return lhs.rawValue <= rhs.rawValue
}

public func >=(lhs: Indentation, rhs: Indentation) -> Bool {
	return lhs.rawValue >= rhs.rawValue
}

public func >(lhs: Indentation, rhs: Indentation) -> Bool {
	return lhs.rawValue > rhs.rawValue
}

public protocol Listable: ReturnCompletable, NativePrefixable, Positionable, NodeContainer, InlineMarkerContainer {
	var indentation: Indentation { get }
	var indentationRange: NSRange { get }
}

func parseListable(string: String, range: NSRange, delimiter: String, prefix: String) -> (nativePrefixRange: NSRange, indentationRange: NSRange, indentation: Indentation, prefixRange: NSRange, visibleRange: NSRange)? {
	let scanner = Scanner(string: string)
	scanner.charactersToBeSkipped = nil

	// Delimiter
	if !scanner.scanString(leadingNativePrefix, into: nil) {
		return nil
	}

	if !scanner.scanString("\(delimiter)-", into: nil) {
		return nil
	}

	let indentationRange = NSRange(location: range.location + scanner.scanLocation, length: 1)
	var indent = -1
	if !scanner.scanInt(&indent) {
		return nil
	}

	guard indent != -1, let indentation = Indentation(rawValue: UInt(indent)) else {
		return nil
	}

	if !scanner.scanString(trailingNativePrefix, into: nil) {
		return nil
	}

	let nativePrefixRange = NSRange(location: range.location, length: scanner.scanLocation)

	// Prefix
	let startPrefix = scanner.scanLocation
	if !scanner.scanString(prefix, into: nil) {
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
