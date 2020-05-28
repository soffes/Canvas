import Foundation

public struct InlineMarkerPair: Node {

    // MARK: - Properties

	public var range: NSRange {
		return openingMarker.range.union(closingMarker.range)
	}

	public var visibleRange: NSRange {
		let location = openingMarker.range.max
		return NSRange(location: location, length: closingMarker.range.location - location)
	}

	public var dictionary: [String: Any] {
		return [
			"type": "inline-marker-pair",
			"openingMarker": openingMarker.dictionary,
			"closingMarker": closingMarker.dictionary
		]
	}

	public var openingMarker: InlineMarker
	public var closingMarker: InlineMarker

    // MARK: - Initializers

	public init(openingMarker: InlineMarker, closingMarker: InlineMarker) {
		self.openingMarker = openingMarker
		self.closingMarker = closingMarker
	}

    // MARK: - Processing

	static func pairs(markers: [InlineMarker]) -> [InlineMarkerPair] {
		var pairs = [InlineMarkerPair]()
		var openingMarkers = [String: InlineMarker]()

		for marker in markers {
			switch marker.position {
			case .opening:
				openingMarkers[marker.id] = marker
			case .closing:
				if let opening = openingMarkers[marker.id] {
					pairs.append(InlineMarkerPair(openingMarker: opening, closingMarker: marker))
				}
			}
		}

		return pairs.sorted { $0.openingMarker.range.location < $1.openingMarker.range.location }
	}

    // MARK: - Node

	public mutating func offset(_ delta: Int) {
		openingMarker.offset(delta)
		closingMarker.offset(delta)
	}
}
