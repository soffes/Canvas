import Foundation

public struct Blockquote: ReturnCompletable, NativePrefixable, Positionable, NodeContainer, InlineMarkerContainer, Equatable {

    // MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange
	public var visibleRange: NSRange
	public var position: Position = .single

	public var textRange: NSRange {
		return visibleRange
	}

	public var subnodes = [SpanNode]()
	public var inlineMarkerPairs = [InlineMarkerPair]()

	public var dictionary: [String: Any] {
		return [
			"type": "blockquote",
			"range": range.dictionary,
			"nativePrefixRange": nativePrefixRange.dictionary,
			"visibleRange": visibleRange.dictionary,
			"position": position.description,
			"subnodes": subnodes.map { $0.dictionary },
			"inlineMarkerPairs": inlineMarkerPairs.map { $0.dictionary }
		]
	}

    // MARK: - Initializers

	public init?(string: String, range: NSRange) {
		guard let (nativePrefixRange, prefixRange, visibleRange) = parseBlockNode(
			string: string,
			range: range,
			delimiter: "blockquote",
			prefix: "> "
		) else {
            return nil
        }

		self.range = range
		self.nativePrefixRange = nativePrefixRange.union(prefixRange)
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

	public static func nativeRepresentation() -> String {
		return "\(leadingNativePrefix)blockquote\(trailingNativePrefix)> "
	}
}

public func == (lhs: Blockquote, rhs: Blockquote) -> Bool {
	return NSEqualRanges(lhs.range, rhs.range) &&
		NSEqualRanges(lhs.nativePrefixRange, rhs.nativePrefixRange) &&
		NSEqualRanges(lhs.visibleRange, rhs.visibleRange) &&
		lhs.position == rhs.position
}
