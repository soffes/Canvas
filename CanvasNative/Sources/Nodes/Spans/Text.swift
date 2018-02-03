import Foundation

public struct Text: SpanNode {

	// MARK: - Properties

	public var range: NSRange

	public var visibleRange: NSRange {
		return range
	}

	public var dictionary: [String: Any] {
		return [
			"type": "text",
			"range": range.dictionary,
			"visibleRange": visibleRange.dictionary
		]
	}


	// MARK: - Initializers

	public init(range: NSRange) {
		self.range = range
	}


	// MARK: - Node

	public mutating func offset(_ delta: Int) {
		range.location += delta
	}
}
