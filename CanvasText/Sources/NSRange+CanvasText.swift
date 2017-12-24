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

	var max: Int {
		return NSMaxRange(self)
	}

	@warn_unused_result
	func equals(range: NSRange) -> Bool {
		return NSEqualRanges(self, range)
	}

	@warn_unused_result
	func intersection(range: NSRange) -> Int? {
		if range.length == 0 {
			return NSLocationInRange(range.location, self) ? 0 : nil
		}

		let length = NSIntersectionRange(self, range).length
		return length > 0 ? length : nil
	}

	@warn_unused_result
	func contains(location: Int) -> Bool {
		return NSLocationInRange(location, self)
	}

	@warn_unused_result
	func union(range: NSRange) -> NSRange {
		return NSUnionRange(self, range)
	}

	static func ranges(indices indices: Set<Int>) -> [NSRange] {
		var ranges = [NSRange]()
		var range: NSRange?

		let sorted = Array(indices).sort()

		for location in sorted {
			guard var r = range else {
				range = NSRange(location: location, length: 1)
				continue
			}

			if r.max == location {
				r.length += 1
				range = r
				continue
			}

			ranges.append(r)
			range = NSRange(location: location, length: 1)
		}

		if let r = range {
			ranges.append(r)
		}

		return ranges
	}
}
