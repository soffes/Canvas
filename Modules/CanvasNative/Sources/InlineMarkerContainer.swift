import Foundation

public protocol InlineMarkerContainer: BlockNode {
	var inlineMarkerPairs: [InlineMarkerPair] { get set }
}

extension InlineMarkerContainer {
	public var hiddenRanges: [NSRange] {
		var ranges = [NSRange]()

		if let block = self as? NativePrefixable {
			ranges.append(block.nativePrefixRange)
		}

		for pair in inlineMarkerPairs {
			ranges += [
				pair.openingMarker.range,
				pair.closingMarker.range
			]
		}

		return ranges.sorted { $0.location < $1.location }
	}
}
