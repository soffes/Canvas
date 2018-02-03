import Foundation

let leadingNativePrefix = "⧙"
let trailingNativePrefix = "⧘"

public protocol NativePrefixable: BlockNode {
	var nativePrefixRange: NSRange { get }
}

func parseBlockNode(string: String, range: NSRange, delimiter: String, prefix: String) -> (nativePrefixRange: NSRange, prefixRange: NSRange, visibleRange: NSRange)? {
	let scanner = Scanner(string: string)
	scanner.charactersToBeSkipped = nil

	// Delimiter
	if !scanner.scanString("\(leadingNativePrefix)\(delimiter)\(trailingNativePrefix)", into: nil) {
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

	return (nativePrefixRange, prefixRange, visibleRange)
}

func parseBlockNode(string: String, range: NSRange, delimiter: String) -> (nativePrefixRange: NSRange, visibleRange: NSRange)? {
	let scanner = Scanner(string: string)
	scanner.charactersToBeSkipped = nil

	// Delimiter
	if !scanner.scanString("\(leadingNativePrefix)\(delimiter)\(trailingNativePrefix)", into: nil) {
		return nil
	}
	let nativePrefixRange = NSRange(location: range.location, length: scanner.scanLocation)

	// Content
	let visibleRange = NSRange(
		location: range.location + scanner.scanLocation,
		length: range.length - scanner.scanLocation
	)

	return (nativePrefixRange, visibleRange)
}
