//
//  NoncontiguousRange.swift
//  CanvasNative
//
//  Created by Sam Soffes on 6/10/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

struct NoncontiguousRange {

	// MARK: - Private

	private var storage = Set<Int>()

	var ranges: [NSRange] {
		return self.dynamicType.ranges(indices: storage)
	}


	// MARK: - Initializers

	init(ranges: [NSRange]) {
		storage = ranges.map { NoncontiguousRange.indices(range: $0) }.reduce(Set<Int>()) { $0.union($1) }
	}


	// MARK: - Querying

	func intersection(range: NSRange) -> Int? {
		if range.length == 0 {
			return storage.contains(range.location) ? 0 : nil
		}

		let indices = self.dynamicType.indices(range: range)
		return storage.intersect(indices).count
	}


	// MARK: - Mutating

	mutating func insert(range range: NSRange) {
		let indices = self.dynamicType.indices(range: range)
		storage.unionInPlace(indices)
	}

	mutating func remove(range range: NSRange) {
		let indices = self.dynamicType.indices(range: range)
		storage.subtractInPlace(indices)
	}


	// MARK: - Private

	private static func indices(range range: NSRange) -> Set<Int> {
		var indicies = Set<Int>()

		for i in range.location..<NSMaxRange(range) {
			indicies.insert(i)
		}

		return indicies
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
