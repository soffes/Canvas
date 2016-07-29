//
//  Cursor.swift
//  CanvasCore
//
//  Created by Sam Soffes on 6/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import CanvasNative

public struct Cursor: Equatable {

	// MARK: - Properties

	/// Index of line on which the user's cursor begins
	public var startLine: UInt

	/// Index of user's cursor start on `startLine`
	public var start: UInt

	/// Index of line on which user's cursor ends
	public var endLine: UInt

	/// Index of user's cursor end on `endLine`
	public var end: UInt

	public var dictionary: [String: UInt] {
		return [
			"startLine": startLine,
			"start": start,
			"endLine": endLine,
			"end": end
		]
	}


	// MARK: - Initializers

	public init?(presentationSelectedRange selection: NSRange, document: Document) {
		var starts: (UInt, UInt)?
		var ends: (UInt, UInt)?

		let max = NSMaxRange(selection)

		let count = document.blocks.count
		for (i, block) in document.blocks.enumerate() {
			let index = UInt(i)
			let isLast = i == count - 1
			var blockRange = document.presentationRange(block: block)

			if !isLast {
				blockRange.length += 1
			}

			// Find start
			if starts == nil && ((!isLast && NSMaxRange(blockRange) > selection.location) || (isLast && NSMaxRange(blockRange) >= selection.location)) {
				starts = (index, UInt(selection.location - blockRange.location))

				if selection.length == 0 {
					ends = starts
				}
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

	public init(startLine: UInt, start: UInt, endLine: UInt, end: UInt) {
		self.startLine = startLine
		self.start = start
		self.endLine = endLine
		self.end = end
	}

	public init?(dictionary: [String: AnyObject]) {
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

	public func presentationRange(with document: Document) -> NSRange {
		var range = NSRange(location: 0, length: 0)

		let count = document.blocks.count
		for (i, block) in document.blocks.enumerate() {
			let index = UInt(i)
			let isLast = i == count - 1
			var blockRange = document.presentationRange(block: block)

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


public func ==(lhs: Cursor, rhs: Cursor) -> Bool {
	return lhs.startLine == rhs.startLine && lhs.start == rhs.start && lhs.endLine == rhs.endLine && lhs.end == rhs.end
}
