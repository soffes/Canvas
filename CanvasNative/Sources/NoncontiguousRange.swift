import Foundation

struct NoncontiguousRange {

	// MARK: - Private

	fileprivate var storage = Set<Int>()

	var ranges: [NSRange] {
		return type(of: self).ranges(indices: storage)
	}


	// MARK: - Initializers

	init(ranges: [NSRange]) {
		storage = ranges.map { NoncontiguousRange.indices(range: $0) }.reduce(Set<Int>()) { $0.union($1) }
	}


	// MARK: - Querying

	func intersectionLength(_ range: NSRange) -> Int? {
		if range.length == 0 {
			return storage.contains(range.location) ? 0 : nil
		}

		let indices = type(of: self).indices(range: range)
		return storage.intersection(indices).count
	}


	// MARK: - Mutating

	mutating func insert(range: NSRange) {
		let indices = type(of: self).indices(range: range)
		storage.formUnion(indices)
	}

	mutating func remove(range: NSRange) {
		let indices = type(of: self).indices(range: range)
		storage.subtract(indices)
	}


	// MARK: - Private

	fileprivate static func indices(range: NSRange) -> Set<Int> {
		var indicies = Set<Int>()

		for i in range.location..<NSMaxRange(range) {
			indicies.insert(i)
		}

		return indicies
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
