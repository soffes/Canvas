import Foundation

public struct InlineMarker: Node {

    // MARK: - Types

	public enum Position: Int {
		case opening
		case closing
	}

    // MARK: - Properties

	static let regularExpression = (try? NSRegularExpression(pattern: "(☊(Ω)?([a-z]{2})\\|([a-zA-Z0-9]{22})☋)",
															 options: []))!

	public var range: NSRange

	public var visibleRange: NSRange {
		return NSRange(location: range.location, length: 0)
	}

	public var dictionary: [String: Any] {
		return [
			"type": "inline-marker",
			"range": range.dictionary,
			"position": position.rawValue,
			"id": id
		]
	}

	public var position: Position
	public var id: String

    // MARK: - Initializers

	public init(range: NSRange, position: Position, id: String) {
		self.range = range
		self.position = position
		self.id = id
	}

    // MARK: - Node

	public mutating func offset(_ delta: Int) {
		range.location += delta
	}
}
