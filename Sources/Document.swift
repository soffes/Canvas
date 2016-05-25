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

	/// The title of the document
	public var title: String? {
		guard let title = blocks.first as? Title else { return nil }

		let range = presentationRange(block: title)
		if range.length == 0 {
			return nil
		}
		return (presentationString as NSString).substringWithRange(range)
	}

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
				presentationRange.length -= intersection
			}
		}

		return presentationRange
	}

	public func presentationRange(block block: BlockNode) -> NSRange {
		guard let index = indexOf(block: block) else { return block.visibleRange }
		return NSRange(location: blockPresentationLocations[index], length: block.visibleRange.length)
	}

	public func presentationRange(blockIndex index: Int) -> NSRange {
		let block = blocks[index]
		return NSRange(location: blockPresentationLocations[index], length: block.visibleRange.length)
	}

	public func backingRange(presentationRange presentationRange: NSRange) -> NSRange {
		var backingRange = presentationRange

		for block in blocks {
			guard let range = (block as? NativePrefixable)?.nativePrefixRange else { continue }

			// Shadow starts after backing range
			// If the block is Attachable, make this inclusive so we delete the entire block.
			if (block is Attachable && range.location >= backingRange.location) || range.location > backingRange.location {

				// Shadow intersects. Expand length.
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

		let presentationRange = self.presentationRange(block: block)
		return presentationRange.contains(presentationLocation) || presentationRange.max == presentationLocation ? block : nil
	}

	public func blockAt(backingLocation backingLocation: Int) -> BlockNode? {
		guard backingLocation >= 0  else { return nil }
		for (i, block) in blocks.enumerate() {
			if backingLocation < block.range.location {
				return blocks[i - 1]
			}
		}

		guard let block = blocks.last else { return nil }
		
		return block.range.contains(backingLocation) || block.range.max == backingLocation ? block : nil
	}

	public func blocksIn(presentationRange presentationRange: NSRange) -> [BlockNode] {
		return blocks.filter { block in
			var range = self.presentationRange(block: block)
			range.length += 1
			return range.intersection(presentationRange) != nil
		}
	}

	public func nodesIn(backingRange backingRange: NSRange) -> [Node] {
		return nodesIn(backingRange: backingRange, nodes: blocks.map({ $0 as Node }))
	}

	private func nodesIn(backingRange backingRange: NSRange, nodes: [Node]) -> [Node] {
		var results = [Node]()

		for node in nodes {
			if node.range.intersection(backingRange) != nil {
				results.append(node)

				if let node = node as? NodeContainer {
					results += nodesIn(backingRange: backingRange, nodes: node.subnodes.map { $0 as Node })
				}
			}
		}

		return results
	}

	public func indexOf(block block: BlockNode) -> Int? {
		return blocks.indexOf({ NSEqualRanges($0.range, block.range) })
	}


	// MARK: - Presentation String

	public func presentationString(block block: BlockNode) -> String {
		return text.substringWithRange(block.visibleRange)
	}


	// MARK: - Block Calculations

	public func characterLengthOfBlocks(blocks: [BlockNode]) -> UInt {
		return blocks.map { UInt($0.range.length) }.reduce(0, combine: +)
	}

	public func presentationString(backingRange backingRange: NSRange) -> String? {
		return documentPresentationString(backingString: backingString, backingRange: backingRange, blocks: blocks)
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
	// of problems later. The first location must start at the beginning.
	assert(!presentationLocations.isEmpty && presentationLocations[0] == 0, "Invalid presentations locations.")

	return presentationLocations
}

private func documentPresentationString(backingString backingString: String, backingRange inBackingRange: NSRange? = nil, blocks: [BlockNode]) -> String? {
	let backingRange = inBackingRange ?? NSRange(location: 0, length: (backingString as NSString).length)

	var components = [String]()

	for block in blocks {
		if block.range.max <= backingRange.location {
			continue
		}

		if block.range.location > backingRange.max {
			break
		}

		let content = block.contentInString(backingString)
		var component: String

		// Offset if starting out
		if components.isEmpty && backingRange.location > block.range.location {
			let offset = backingRange.location - block.visibleRange.location
			if offset < 0 {
				continue
			}
			component = (content as NSString).substringFromIndex(offset) as String
		} else {
			component = content
		}

		// Offset the end of it's too long
		let delta = block.range.max - backingRange.max
		if delta > 0 {
			let string = component as NSString
			component = string.substringWithRange(NSRange(location: 0, length: string.length - delta))
		}

		components.append(component)
	}

	return components.isEmpty ? nil : components.joinWithSeparator("\n")
}
