//
//  NSRange+CanvasNative.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

extension NSRange {

	// MARK: - Properties

	var max: Int {
		return NSMaxRange(self)
	}

	static let zero = NSRange(location: 0, length: 0)

	var dictionary: [String: AnyObject] {
		return [
			"location": location,
			"length": length
		]
	}

	var range: Range<Int> {
		return location..<max
	}

	
	// MARK: - Initializers

	init(_ range: Range<Int>) {
		location = range.startIndex
		length = range.count
	}

	init(location: UInt, length: UInt) {
		self.init(location: Int(location), length: Int(length))
	}
	
	init(location: UInt, length: Int) {
		self.init(location: Int(location), length: length)
	}
	
	init(location: Int, length: UInt) {
		self.init(location: location, length: Int(length))
	}


	// MARK: - Working with Locations

	@warn_unused_result
	func contains(location: UInt) -> Bool {
		return contains(Int(location))
	}

	@warn_unused_result
	func contains(location: Int) -> Bool {
		return NSLocationInRange(location, self)
	}


	// MARK: - Working with other Ranges

	@warn_unused_result
	func union(range: NSRange) -> NSRange {
		return NSUnionRange(self, range)
	}

	/// Returns nil if they don't intersect. Their intersection may be 0 if one of the ranges has a zero length.
	///
	/// - parameter range: The range to check for intersection with the receiver.
	/// - return: The length of intersection if they intersect or nil if they don't.
	@warn_unused_result
	func intersection(range: NSRange) -> Int? {
		if range.length == 0 {
			return NSLocationInRange(range.location, self) ? 0 : nil
		}

		let length = NSIntersectionRange(self, range).length
		return length > 0 ? length : nil
	}

	@warn_unused_result
	func equals(range: NSRange) -> Bool {
		return NSEqualRanges(self, range)
	}
}
