//
//  Cursor.swift
//  CanvasCore
//
//  Created by Sam Soffes on 6/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

struct Cursor {

	// MARK: - Properties

	/// Index of line on which the user's cursor begins
	var startLine: UInt

	/// Index of user's cursor start on `startLine`
	var start: UInt

	/// Index of line on which user's cursor ends
	var endLine: UInt

	/// Index of user's cursor end on `endLine`
	var end: UInt


	// MARK: - Initializers

	/// Initialize a cursor with a backing selection and backing string.
	///
	/// - parameter selectedRange: A selection in the backing string.
	/// - parameter string: A backing string.
	init?(selectedRange: NSRange, string: String) {
		let text = string as NSString
		let bounds = NSRange(location: 0, length: text.length)

		// If the selection is longer than the string, it's invaid.
		let max = NSMaxRange(selectedRange)
		if max > bounds.length {
			return nil
		}

		var starts: (UInt, UInt)?
		var ends: (UInt, UInt)?
		var index: UInt = 0

		// Interate through lines
		text.enumerateSubstringsInRange(bounds, options: .ByLines) { _, _, enclosingRange, stop in
			// Find start
			if starts == nil && NSMaxRange(enclosingRange) > selectedRange.location  {
				starts = (index, UInt(selectedRange.location - enclosingRange.location))
			}

			// Find end
			if ends == nil && NSMaxRange(enclosingRange) >= max {
				ends = (index, UInt(max - enclosingRange.location))
			}

			// Stop if we've found both
			if starts != nil && ends != nil {
				stop.memory = true
				return
			}

			index += 1
		}

		guard let (startLine, start) = starts, (endLine, end) = ends else { return nil }

		self.startLine = startLine
		self.start = start
		self.endLine = endLine
		self.end = end
	}

	init(startLine: UInt, start: UInt, endLine: UInt, end: UInt) {
		self.startLine = startLine
		self.start = start
		self.endLine = endLine
		self.end = end
	}


	// MARK: - Converting to NSRange

	func range(with string: String) -> NSRange {
		var range = NSRange(location: 0, length: 0)

		let text = string as NSString
		let bounds = NSRange(location: 0, length: text.length)
		var index: UInt = 0

		text.enumerateSubstringsInRange(bounds, options: .ByLines) { _, _, enclosingRange, stop in
			if index < self.startLine {
				range.location += enclosingRange.length
			} else if self.startLine == index {
				range.location += Int(self.start)
			}

			if self.endLine < index {
				if self.endLine != self.startLine {
					range.length += enclosingRange.length
				}
			} else if self.endLine == index {
				range.length = enclosingRange.location + Int(self.end) - range.location
				stop.memory = true
				return
			}

			index += 1
		}

		return range
	}
}
