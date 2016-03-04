//
//  NSRange+CanvasText.swift
//  Canvas
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

extension NSRange {
	var indices: Set<Int> {
		var indicies = Set<Int>()

		for i in location..<(location + length) {
			indicies.insert(Int(i))
		}

		return indicies
	}

	func equals(range: NSRange) -> Bool {
		return NSEqualRanges(self, range)
	}

	func intersection(range: NSRange) -> Int? {
		if range.length == 0 {
			return NSLocationInRange(range.location, self) ? 0 : nil
		}

		let length = NSIntersectionRange(self, range).length
		return length > 0 ? length : nil
	}

	func contains(location: Int) -> Bool {
		return NSLocationInRange(location, self)
	}
}
