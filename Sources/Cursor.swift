//
//  Cursor.swift
//  CanvasCore
//
//  Created by Sam Soffes on 6/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import CanvasNative

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

	var dictionary: [String: UInt] {
		return [
			"startLine": startLine,
			"start": start,
			"endLine": endLine,
			"end": end
		]
	}


	// MARK: - Initializers

	init?(backingSelection: NSRange, document: Document) {
		var starts: (UInt, UInt)?
		var ends: (UInt, UInt)?

		let max = NSMaxRange(backingSelection)

		let count = document.blocks.count
		for (i, block) in document.blocks.enumerate() {
			let index = UInt(i)
			let isLast = i == count - 1
			var blockRange = block.range

			if !isLast {
				blockRange.length += 1
			}

			// Find start
			if starts == nil && NSMaxRange(blockRange) > backingSelection.location  {
				starts = (index, UInt(backingSelection.location - blockRange.location))
			}

			// Find end
			if ends == nil && NSMaxRange(blockRange) >= max {
				ends = (index, UInt(max - blockRange.location))
			}

			// Stop if we've found both
			if starts != nil && ends != nil {
				break
			}
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

	init?(dictionary: [String: AnyObject]) {
		guard let startLine = dictionary["startLine"] as? UInt,
			start = dictionary["start"] as? UInt,
			endLine = dictionary["endLine"] as? UInt,
			end = dictionary["end"] as? UInt
		else { return nil }

		self.startLine = startLine
		self.start = start
		self.endLine = endLine
		self.end = end
	}


	// MARK: - Converting to NSRange

	func range(with document: Document) -> NSRange {
		var range = NSRange(location: 0, length: 0)

		let count = document.blocks.count
		for (i, block) in document.blocks.enumerate() {
			let index = UInt(i)
			let isLast = i == count - 1
			var blockRange = block.range

			if !isLast {
				blockRange.length += 1
			}

			if index < self.startLine {
				range.location += blockRange.length
			} else if self.startLine == index {
				range.location += Int(self.start)
			}

			if self.endLine < index {
				if self.endLine != self.startLine {
					range.length += blockRange.length
				}
			} else if self.endLine == index {
				range.length = blockRange.location + Int(self.end) - range.location
				break
			}
		}

		return range
	}
}
