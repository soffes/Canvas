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


	func equals(_ range: NSRange) -> Bool {
		return NSEqualRanges(self, range)
	}


	func contains(_ location: Int) -> Bool {
		return NSLocationInRange(location, self)
	}


	func union(_ range: NSRange) -> NSRange {
		return NSUnionRange(self, range)
	}

	static func ranges(indices: Set<Int>) -> [NSRange] {
		var ranges = [NSRange]()
		var range: NSRange?

		let sorted = Array(indices).sorted()

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
