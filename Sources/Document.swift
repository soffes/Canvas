//
//  Document.swift
//  CanvasNative
//
//  Created by Sam Soffes on 4/11/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

/// Model that contains Canvas Native backing string, BlockNodes, and presentation string. Several methods for doing
/// calculations on the strings or nodes are provided.
public struct Document {

	// MARK: - Properties

	/// Backing Canvas Native string
	public let backingString: String

	/// Presentation string for use in a text view
	public let presentationString: String

	/// Models for each line
	public let blocks: [BlockNode]

	private var text: NSString {
		return backingString as NSString
	}

	private let blockPresentationLocations: [Int]


	// MARK: - Initializers

	public init() {
		backingString = ""
		blocks = []
		blockPresentationLocations = []
		presentationString = ""
	}

	public init(backingString: String, blocks: [BlockNode]? = nil) {
		self.backingString = backingString
		self.blocks = blocks ?? Parser.parse(backingString)
		blockPresentationLocations = documentPresentationLocations(blocks: self.blocks)
		presentationString = documentPresentationString(backingString: backingString, blocks: self.blocks) ?? ""
	}


	// MARK: - Range Calculations

	public func presentationRange(backingRange backingRange: NSRange) -> NSRange {
		var presentationRange = backingRange

		for block in blocks {
			guard let prefixRange = (block as? NativePrefixable)?.nativePrefixRange else { continue }

			if prefixRange.max <= backingRange.location {
				presentationRange.location -= prefixRange.length
			} else if let intersection = backingRange.intersection(prefixRange) {
//				presentationRange.location -= intersection
				presentationRange.length -= intersection
			}
		}

		return presentationRange
	}

	public func backingRange(presentationRange presentationRange: NSRange) -> NSRange {
		var backingRange = presentationRange

		for block in blocks {
			guard let range = (block as? NativePrefixable)?.nativePrefixRange else { continue }

			// Shadow starts after backing range
			if range.location > backingRange.location {

				// Shadow intersects. Expand lenght.
				if backingRange.intersection(range) > 0 {
					backingRange.length += range.length
					continue
				}

				// If the shadow starts directly after the backing range, expand to include it.
				if range.location == backingRange.max {
					backingRange.length += range.length
				}

				break
			}

			backingRange.location += range.length
		}

		return backingRange
	}

	public func blockAt(presentationLocation presentationLocation: Int) -> BlockNode? {
		guard presentationLocation >= 0  else { return nil }
		for (i, location) in blockPresentationLocations.enumerate() {
			if presentationLocation < location {
				return blocks[i - 1]
			}
		}

		guard let block = blocks.last else { return nil }
		return presentationRange(backingRange: block.visibleRange).contains(presentationLocation) ? block : nil
	}

	public func blockAt(backingLocation backingLocation: Int) -> BlockNode? {
		guard backingLocation >= 0  else { return nil }
		for (i, block) in blocks.enumerate() {
			if backingLocation < block.range.location {
				return blocks[i - 1]
			}
		}

		guard let block = blocks.last else { return nil }
		return block.range.contains(backingLocation) ? block : nil
	}


	// MARK: - Presentation String

	public func presentationString(block block: BlockNode) -> String {
		return text.substringWithRange(block.visibleRange)
	}


	// MARK: - Block Calculations

	public func characterLengthOfBlocks(blocks: [BlockNode]) -> UInt {
		return blocks.map { UInt($0.range.length) }.reduce(0, combine: +)
	}

	public func blockRangeForCharacterRange(range: NSRange, string: String) -> NSRange {
		var location: Int?
		var matchingBlocks = [BlockNode]()

		let hasNewLinePrefix = string.hasPrefix("\n")

		for (i, block) in blocks.enumerate() {
			if block.enclosingRange.intersection(range) != nil || block.enclosingRange.max == range.location && hasNewLinePrefix {
				// Detect inserting at the end of a line vs inserting a new block
				if block.newLineRange != nil && range.location == block.range.max && hasNewLinePrefix {
					if i + 1 == blocks.count {
						return NSRange(location: i, length: 1)
					}
					return NSRange(location: min(i + 1, blocks.endIndex), length: 0)
				}

				// Start if we haven't already
				if location == nil {
					location = i
				}

				matchingBlocks.append(block)
			} else if location != nil {
				// This block didn't match and we've already started, so end the range.
				break
			}
		}

		// Nothing found. Editing the last block.
		if !blocks.isEmpty && location == nil && matchingBlocks.isEmpty && !hasNewLinePrefix, let last = blocks.last {
			// If the last block doesn't end in a new line and we didn't insert one, we're editing it.
			if last.enclosingRange.length > 0 && text.substringWithRange(NSRange(location: last.enclosingRange.max - 1, length: 1)) != "\n" {
				return NSRange(location: blocks.count - 1, length: 1)
			}
		}

		// If we didn't find anything, assume we're inserting at the very end.
		var blockRange = NSRange(location: location ?? blocks.endIndex, length: matchingBlocks.count)

		// If we delete the new line in the last block, extend the length if possible.
		if string.isEmpty, let lastNewLine = matchingBlocks.last?.newLineRange where lastNewLine.intersection(range) == 1 {
			blockRange.length = min(blockRange.length + 1, blocks.count - blockRange.location)
		}

		return blockRange
	}

	public func presentationString(backingRange backingRange: NSRange) -> String? {
		var output = ""

		for block in blocks {
			if block.enclosingRange.max <= backingRange.location {
				continue
			}

			if block.enclosingRange.location > backingRange.max {
				break
			}

			let content = block.contentInString(backingString)
			var component: String

			// Offset if starting out
			if output.isEmpty && backingRange.location > block.enclosingRange.location {
				let offset = backingRange.location - block.visibleRange.location
				if offset < 0 {
					continue
				}
				component = (content as NSString).substringFromIndex(offset) as String
			} else {
				component = content
			}

			// Add new line
			if block.newLineRange != nil {
				component += "\n"
			}

			// Offset the end of it's too long
			let delta = block.enclosingRange.max - backingRange.max
			if delta > 0 {
				let string = component as NSString
				component = string.substringWithRange(NSRange(location: 0, length: string.length - delta))
			}

			output += component
		}

		return output.isEmpty ? nil : output
	}
}


private func documentPresentationLocations(blocks blocks: [BlockNode]) -> [Int] {
	// Calculate block presentation locations
	var offset = 0
	var presentationLocations = [Int]()

	for block in blocks {
		if let range = (block as? NativePrefixable)?.nativePrefixRange {
			offset += range.length
		}

		presentationLocations.append(block.visibleRange.location - offset)
	}

	// Ensure the newly calculated presentations locations are accurate. If these are wrong, there will be all sorts
	// of problems later.
	if !presentationLocations.isEmpty {
		// The first location must start at the beginning.
		assert(presentationLocations[0] == 0, "Invalid presentations locations.")
	}

	return presentationLocations
}

private func documentPresentationString(backingString backingString: String, backingRange inBackingRange: NSRange? = nil, blocks: [BlockNode]) -> String? {
	let backingRange = inBackingRange ?? NSRange(location: 0, length: (backingString as NSString).length)
	var output = ""

	for block in blocks {
		if block.enclosingRange.max <= backingRange.location {
			continue
		}

		if block.enclosingRange.location > backingRange.max {
			break
		}

		let content = block.contentInString(backingString)
		var component: String

		// Offset if starting out
		if output.isEmpty && backingRange.location > block.enclosingRange.location {
			let offset = backingRange.location - block.visibleRange.location
			if offset < 0 {
				continue
			}
			component = (content as NSString).substringFromIndex(offset) as String
		} else {
			component = content
		}

		// Add new line
		if block.newLineRange != nil {
			component += "\n"
		}

		// Offset the end of it's too long
		let delta = block.enclosingRange.max - backingRange.max
		if delta > 0 {
			let string = component as NSString
			component = string.substringWithRange(NSRange(location: 0, length: string.length - delta))
		}

		output += component
	}

	return output.isEmpty ? nil : output
}
