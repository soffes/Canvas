//
//  Document.swift
//  CanvasNative
//
//  Created by Sam Soffes on 4/11/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

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

		let titleDocument = Document(backingString: backingString, blocks: [title])
		let renderer = PlainRenderer(document: titleDocument)
		return renderer.render()
	}

	private var text: NSString {
		return backingString as NSString
	}

	private let hiddenRanges: [NSRange]
	private let blockRanges: [NSRange]


	// MARK: - Initializers

	public init(backingString: String = "", blocks: [BlockNode]? = nil) {
		self.backingString = backingString
		self.blocks = blocks ?? Parser.parse(backingString)
		(presentationString, hiddenRanges, blockRanges) = Document.present(backingString: backingString, blocks: self.blocks)
	}


	// MARK: - Converting Backing Ranges to Presentation Ranges

	public func presentationRange(backingRange backingRange: NSRange) -> NSRange {
		var presentationRange = backingRange

		for block in blocks {
			// Done adjusting
			if block.range.location > backingRange.max {
				break
			}

			// Inline markers
			if let block = block as? InlineMarkerContainer {
				presentationRange = remove(inlineMarkerPairs: block.inlineMarkerPairs, presentationRange: presentationRange, backingRange: backingRange)
			}

			// Native prefix
			if let prefixRange = (block as? NativePrefixable)?.nativePrefixRange {
				presentationRange = remove(range: prefixRange, presentationRange: presentationRange, backingRange: backingRange)
			}
		}

		return presentationRange
	}

	public func presentationRange(block block: BlockNode) -> NSRange {
		guard let index = indexOf(block: block) else { return block.visibleRange }
		return presentationRange(blockIndex: index)
	}

	public func presentationRange(blockIndex index: Int) -> NSRange {
		return blockRanges[index]
	}

	public func blockAt(presentationLocation presentationLocation: Int) -> BlockNode? {
		guard presentationLocation >= 0  else { return nil }
		return blockAt(presentationLocation: UInt(presentationLocation))
	}

	public func blockAt(presentationLocation presentationLocation: UInt) -> BlockNode? {
		for (i, range) in blockRanges.enumerate() {
			if Int(presentationLocation) < range.location {
				return blocks[i - 1]
			}
		}

		guard let block = blocks.last else { return nil }

		let presentationRange = self.presentationRange(block: block)
		return presentationRange.contains(presentationLocation) || presentationRange.max == Int(presentationLocation) ? block : nil
	}

	public func blocksIn(presentationRange presentationRange: NSRange) -> [BlockNode] {
		return blocks.filter { block in
			var range = self.presentationRange(block: block)
			range.length += 1
			return range.intersection(presentationRange) != nil
		}
	}

	/// Remove a range from a presentation range.
	///
	/// - parameter range: Backing range to remove
	/// - parameter presentationRange: Working presentation range
	/// - parameter backingRange: Original backing range
	/// - returns: Updated presentation range
	private func remove(range range: NSRange, presentationRange: NSRange, backingRange: NSRange) -> NSRange {
		var presentationRange = presentationRange
		if range.max <= backingRange.location {
			presentationRange.location -= range.length
		} else if let intersection = backingRange.intersection(range) {
			presentationRange.length -= intersection
		}
		return presentationRange
	}

	/// Remove an inline marker from a presentation range.
	///
	/// - parameter inlineMarkerPairs: Array of inline marker pairs
	/// - parameter presentationRange: Working presentation range
	/// - parameter backingRange: Original backing range
	/// - returns: Updated presentation range
	private func remove(inlineMarkerPairs inlineMarkerPairs: [InlineMarkerPair], presentationRange: NSRange, backingRange: NSRange) -> NSRange {
		var presentationRange = presentationRange
		for pair in inlineMarkerPairs {
			presentationRange = remove(range: pair.openingMarker.range, presentationRange: presentationRange, backingRange: backingRange)
			presentationRange = remove(range: pair.closingMarker.range, presentationRange: presentationRange, backingRange: backingRange)
		}
		return presentationRange
	}


	// MARK: - Converting Presentation Ranges to Backing Ranges

	public func backingRange(presentationRange presentationRange: NSRange) -> NSRange {
		var backingRange = presentationRange

		func addRange(range: NSRange, inclusive: Bool = false) {
			// Shadow starts after backing range
			if (inclusive && range.location >= backingRange.location) || range.location > backingRange.location {

				// Shadow intersects. Expand length.
				if backingRange.intersection(range) > 0 {
					backingRange.length += range.length
					return
				}

				// If the shadow starts directly after the backing range, expand to include it.
				if range.location == backingRange.max {
					backingRange.length += range.length
				}
				return
			}

			backingRange.location += range.length
		}

		for block in blocks {
			// Inline markers
			if let block = block as? InlineMarkerContainer {
				for pair in block.inlineMarkerPairs {
					addRange(pair.openingMarker.range, inclusive: true)

					// TODO: delete entire pair

					if presentationRange.length == 0 || (presentationRange.length > 0 && backingRange.max != pair.closingMarker.range.location) {
						addRange(pair.closingMarker.range, inclusive: true)
					}
				}
			}

			// Native prefix
			if let range = (block as? NativePrefixable)?.nativePrefixRange {
				addRange(range, inclusive: block is Attachable)
			}
		}

		if presentationRange.length == 0 {
			backingRange.length = 0
		}

		return backingRange
	}

	public func blockAt(backingLocation backingLocation: Int) -> BlockNode? {
		guard backingLocation >= 0  else { return nil }
		return blockAt(backingLocation: UInt(backingLocation))
	}

	public func blockAt(backingLocation backingLocation: UInt) -> BlockNode? {
		guard backingLocation >= 0  else { return nil }
		for (i, block) in blocks.enumerate() {
			if Int(backingLocation) < block.range.location {
				return blocks[i - 1]
			}
		}

		guard let block = blocks.last else { return nil }

		return block.range.contains(backingLocation) || block.range.max == Int(backingLocation) ? block : nil
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
		return presentationString(backingRange: block.range)
	}


	// MARK: - Block Calculations

	public func presentationString(backingRange backingRange: NSRange) -> String {
		let text = NSMutableString(string: (backingString as NSString).substringWithRange(backingRange))

		var offset = backingRange.location
		for hiddenRange in hiddenRanges {
			// Before the desired ranage
			if hiddenRange.location < backingRange.location {
				continue
			}

			// After the desired range
			if hiddenRange.location > backingRange.max {
				break
			}

			// Adjust hidden range
			var range = hiddenRange
			range.location -= offset
			range.length = min(text.length - range.location, range.length)

			// Remove hidden range from presentation string
			text.replaceCharactersInRange(range, withString: "")
			offset += range.length
		}

		return text as String
	}


	// MARK: - Private

	private static func present(backingString backingString: String, blocks: [BlockNode]) -> (String, [NSRange], [NSRange]) {
		let text = backingString as NSString

		var presentationString = ""
		var hiddenRanges = [NSRange]()
		var blockRanges = [NSRange]()
		var location: Int = 0

		for (i, block) in blocks.enumerate() {
			let isLast = i == blocks.count - 1
			var blockRange = NSRange(location: location, length: 0)
			hiddenRanges += block.hiddenRanges
			
			if block is Attachable {
				// Special case for attachments
				presentationString += String(Character(UnicodeScalar(NSAttachmentCharacter)))
				location += 1
			} else {
				// Get the raw text of the line
				let line = NSMutableString(string: text.substringWithRange(block.range))

				// Remove hidden ranges
				var offset = block.range.location
				for range in block.hiddenRanges {
					line.replaceCharactersInRange(NSRange(location: range.location - offset, length: range.length), withString: "")
					offset += range.length
				}

				presentationString += line as String
				location += block.range.length - offset + block.range.location
			}

			// Add block range.
			blockRange.length = location - blockRange.location
			blockRanges.append(blockRange)

			// New line if we're not at the end. This isn't included in the block's range.
			if !isLast {
				presentationString += "\n"
				location += 1
			}
		}

		return (presentationString, hiddenRanges, blockRanges)
	}
}
