import Foundation

public protocol NodeContainer: Node {
	/// Range of text to parse inline elements
	var textRange: NSRange { get }

	/// Nodes for inline elements
	var subnodes: [SpanNode] { get set }
}
