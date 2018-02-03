import Foundation

public struct Title: NativePrefixable, NodeContainer, InlineMarkerContainer, Equatable {

    // MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange
	public var visibleRange: NSRange

	public var textRange: NSRange {
		return visibleRange
	}

	public var subnodes = [SpanNode]()
	public var inlineMarkerPairs = [InlineMarkerPair]()

	public var dictionary: [String: Any] {
		return [
			"type": "title",
			"range": range.dictionary,
			"nativePrefixRange": nativePrefixRange.dictionary,
			"visibleRange": visibleRange.dictionary,
			"subnodes": subnodes.map { $0.dictionary },
			"inlineMarkerPairs": inlineMarkerPairs.map { $0.dictionary }
		]
	}

    // MARK: - Initializers

	public init?(string: String, range: NSRange) {
		guard let (nativePrefixRange, visibleRange) = parseBlockNode(
			string: string,
			range: range,
			delimiter: "doc-heading"
		) else {
            return nil
        }

		self.range = range
		self.nativePrefixRange = nativePrefixRange
		self.visibleRange = visibleRange
	}

    // MARK: - Node

	public mutating func offset(_ delta: Int) {
		range.location += delta
		nativePrefixRange.location += delta
		visibleRange.location += delta

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

    // MARK: - Native

	public static func nativeRepresentation(_ string: String? = nil) -> String {
		return "\(leadingNativePrefix)doc-heading\(trailingNativePrefix)" + (string ?? "")
	}
}

public func ==(lhs: Title, rhs: Title) -> Bool {
	return NSEqualRanges(lhs.range, rhs.range) &&
		NSEqualRanges(lhs.nativePrefixRange, rhs.nativePrefixRange) &&
		NSEqualRanges(lhs.visibleRange, rhs.visibleRange)
}
