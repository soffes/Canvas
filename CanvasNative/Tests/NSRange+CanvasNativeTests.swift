import Foundation

extension NSRange: Equatable {
	static let zero = NSRange(location: 0, length: 0)
}

public func ==(lhs: NSRange, rhs: NSRange) -> Bool {
	return NSEqualRanges(lhs, rhs)
}
