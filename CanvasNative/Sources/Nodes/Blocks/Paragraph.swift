import Foundation

public struct Paragraph: BlockNode, NodeContainer, InlineMarkerContainer, Equatable {

    // MARK: - Properties

	public var range: NSRange

	public var visibleRange: NSRange {
		return range
	}

	public var textRange: NSRange {
		return range
	}

	public var subnodes = [SpanNode]()
	public var inlineMarkerPairs = [InlineMarkerPair]()

	public var dictionary: [String: Any] {
		return [
			"type": "paragraph",
			"range": range.dictionary,
			"visibleRange": visibleRange.dictionary,
			"subnodes": subnodes.map { $0.dictionary },
			"inlineMarkerPairs": inlineMarkerPairs.map { $0.dictionary }
		]
	}

    // MARK: - Initializers

	public init?(string: String, range: NSRange) {
		self.range = range
	}

	public init(range: NSRange, subnodes: [SpanNode]? = nil) {
		self.range = range
		self.subnodes = subnodes ?? []
	}

    // MARK: - Node

	public mutating func offset(_ delta: Int) {
		range.location += delta

		subnodes = subnodes.map {
			var node = $0
			node.offset(delta)
			return node
		}

		inlineMarkerPairs = inlineMarkerPairs.map {
			var pair = $0
			pair.offset(delta)
			return pair
		}
	}
}


public func ==(lhs: Paragraph, rhs: Paragraph) -> Bool {
	return NSEqualRanges(lhs.range, rhs.range)
}
