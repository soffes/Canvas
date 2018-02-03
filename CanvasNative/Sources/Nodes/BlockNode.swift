import Foundation

public protocol BlockNode: Node {
	/// Ranges hidden from visible the presentation string
	var hiddenRanges: [NSRange] { get }

	init?(string: String, range: NSRange)
}
