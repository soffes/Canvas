import Foundation

public protocol Attachable: NativePrefixable {}

extension Attachable {
	public var visibleRange: NSRange {
		return NSRange(location: nativePrefixRange.max, length: 1)
	}

	public var hiddenRanges: [NSRange] {
		return [NSRange(location: nativePrefixRange.location, length: nativePrefixRange.length - 1)]
	}
}
