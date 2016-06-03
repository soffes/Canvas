//
//  InlineMarkerContainer.swift
//  CanvasNative
//
//  Created by Sam Soffes on 6/1/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

public protocol InlineMarkerContainer: BlockNode {
	var inlineMarkerPairs: [InlineMarkerPair] { get set }
}


extension InlineMarkerContainer {
	public func contentInString(string: String) -> String {
		let text = NSMutableString(string: string)

		var offset = 0

		func removeMarker(marker: InlineMarker) {
			var range = marker.range
			range.location -= offset
			text.replaceCharactersInRange(range, withString: "")
			offset += range.length
		}

		for pair in inlineMarkerPairs {
			removeMarker(pair.openingMarker)
			removeMarker(pair.closingMarker)
		}

		return text.substringWithRange(NSRange(location: visibleRange.location, length: visibleRange.length - offset))
	}
}