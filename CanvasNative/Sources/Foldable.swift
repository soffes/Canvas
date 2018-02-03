import Foundation

public protocol Foldable: Node {
	// Ideally, this is always 1-2 in length.
	var foldableRanges: [NSRange] { get }
}
