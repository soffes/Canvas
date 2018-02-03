#if os(OSX)
	import AppKit
#else
	import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

#endif

/// Model that contains Canvas Native backing string, BlockNodes, and presentation string. Several methods for doing
/// calculations on the strings or nodes are provided.
public struct Document {

	// MARK: - Types

	public enum Direction: String {
		case leading, trailing
	}


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

	fileprivate let hiddenRanges: [NSRange]
	fileprivate let blockRanges: [NSRange]


	// MARK: - Initializers

	public init(backingString: String = Title.nativeRepresentation(), blocks: [BlockNode]? = nil) {
		self.backingString = backingString
		self.blocks = blocks ?? Parser.parse(backingString)
		(presentationString, hiddenRanges, blockRanges) = Document.present(backingString: backingString, blocks: self.blocks)
	}


	// MARK: - Converting Backing Ranges to Presentation Ranges

	public func presentationRange(backingRange: NSRange) -> NSRange {
		var presentationRange = backingRange

		for hiddenRange in hiddenRanges {
			// After the desired range
			if hiddenRange.location > backingRange.max {
				break
			}

			if hiddenRange.max <= backingRange.location {
				presentationRange.location -= hiddenRange.length
			} else if let intersection = backingRange.intersectionLength(hiddenRange) {
				presentationRange.length -= intersection
			}
		}

		return presentationRange
	}

	public func presentationRange(block: BlockNode) -> NSRange {
		guard let index = indexOf(block: block) else { return block.visibleRange }
		return presentationRange(blockIndex: index)
	}

	public func presentationRange(blockIndex index: Int) -> NSRange {
		return blockRanges[index]
	}


	// MARK: - Converting Presentation Ranges to Backing Ranges

	public func backingRange(presentationLocation: UInt) -> NSRange {
		var backingRange = preBackingRange(NSRange(location: Int(presentationLocation), length: 0))
		let inlineMarkerPairs = blocks.compactMap { ($0 as? InlineMarkerContainer)?.inlineMarkerPairs }.reduce([], +)

		// Adjust for inline markers
		for pair in inlineMarkerPairs {
			// If inserting at the beginning of the pair, do it outside
			if backingRange.location == pair.visibleRange.location {
				backingRange.location = pair.openingMarker.range.location
			}

				// If inserting at the end of the pair, do it outside
			else if backingRange.location == pair.closingMarker.range.max {
				backingRange.location = pair.closingMarker.range.location
			}
		}

		return backingRange
	}

	public func backingRanges(presentationRange: NSRange) -> [NSRange] {
		if presentationRange.length == 0 {
			return [backingRange(presentationLocation: UInt(presentationRange.location))]
		}

		let pre = preBackingRange(presentationRange)

		var output = NoncontiguousRange(ranges: [pre])
		let inlineMarkerPairs = blocks.compactMap { ($0 as? InlineMarkerContainer)?.inlineMarkerPairs }.reduce([], +)

		// Adjust for inline markers
		for pair in inlineMarkerPairs {

			// Delete the entire pair if all of it is in the selection
			if output.intersectionLength(pair.visibleRange) == pair.visibleRange.length {
				output.insert(range: pair.range)
			} else {
				// Remove any markers from the range
				output.remove(range: pair.openingMarker.range)
				output.remove(range: pair.closingMarker.range)
			}
		}

		return output.ranges
	}

	fileprivate func preBackingRange(_ presentationRange: NSRange) -> NSRange {
		var backingRange = presentationRange

		// Account for all hidden ranges
		for hiddenRange in hiddenRanges {
			// Shadow starts after backing range
			if hiddenRange.location > backingRange.location {

				// Shadow intersects. Expand length.
				if let length = backingRange.intersectionLength(hiddenRange), length > 0 {
					backingRange.length += hiddenRange.length
					continue
				}

				// If the shadow starts directly after the backing range, expand to include it.
				if hiddenRange.location == backingRange.max {
					backingRange.length += hiddenRange.length
				}

				break
			}

			backingRange.location += hiddenRange.length
		}

		let isDeleting = presentationRange.length > 0

		// Adjust for blocks
		for block in blocksIn(backingRange: backingRange) {
			// Attachables
			if isDeleting, let attachable = block as? Attachable {
				backingRange = backingRange.union(attachable.range)
			}
		}

		return backingRange
	}


	// MARK: - Querying Blocks

	public func blockAt(backingLocation: Int) -> BlockNode? {
		guard backingLocation >= 0  else { return nil }
		return blockAt(backingLocation: UInt(backingLocation))
	}

	public func blockAt(backingLocation: UInt) -> BlockNode? {
		guard backingLocation >= 0  else { return nil }
		for (i, block) in blocks.enumerated() {
			if Int(backingLocation) < block.range.location {
				return blocks[i - 1]
			}
		}

		guard let block = blocks.last else { return nil }

		return block.range.contains(backingLocation) || block.range.max == Int(backingLocation) ? block : nil
	}

	public func blockAt(presentationLocation: Int, direction: Direction = .leading) -> BlockNode? {
		guard presentationLocation >= 0  else { return nil }
		return blockAt(presentationLocation: UInt(presentationLocation), direction: direction)
	}

	/// Find a blog at a given location in the presentation string.
	///
	/// - parameter presentationLocation: Location in the presentation string
	/// - parameter direction: Specify which block should be returned if the character is a new line.
	/// - returns: A block if one is found.
	public func blockAt(presentationLocation: UInt, direction: Direction = .leading) -> BlockNode? {
		let location = Int(presentationLocation)

		for (i, range) in blockRanges.enumerated() {
			// If it's the new line between two blocks, use the second block
			if direction == .trailing && location + 1 == range.location {
				return blocks[i]
			}

			if location < range.location {
				return blocks[i - 1]
			}
		}

		guard let block = blocks.last else { return nil }

		let presentationRange = self.presentationRange(block: block)
		return presentationRange.contains(presentationLocation) || presentationRange.max == location ? block : nil
	}

	public func blocksIn(presentationRange: NSRange) -> [BlockNode] {
		return blocks.filter { block in
			var range = self.presentationRange(block: block)
			range.length += 1
			return range.intersectionLength(presentationRange) != nil
		}
	}

	public func blocksIn(backingRange: NSRange) -> [BlockNode] {
		return blocks.filter { block in
			var range = block.range
			range.length += 1
			return range.intersectionLength(backingRange) != nil
		}
	}

	public func nodesIn(backingRange: NSRange) -> [Node] {
		return nodesIn(backingRange: backingRange, nodes: blocks.map({ $0 as Node }))
	}

	public func nodesIn(backingRanges: [NSRange]) -> [Node] {
		guard let first = backingRanges.first else { return [] }
		let range = backingRanges.reduce(first) { $0.union($1) }
		return nodesIn(backingRange: range, nodes: blocks.map({ $0 as Node }))
	}

	fileprivate func nodesIn(backingRange: NSRange, nodes: [Node]) -> [Node] {
		var results = [Node]()

		for node in nodes {
			if node.range.intersectionLength(backingRange) != nil {
				results.append(node)

				if let node = node as? NodeContainer {
					results += nodesIn(backingRange: backingRange, nodes: node.subnodes.map { $0 as Node })
				}
			}
		}

		return results
	}

	public func indexOf(block: BlockNode) -> Int? {
		return blocks.index(where: { NSEqualRanges($0.range, block.range) })
	}


	// MARK: - Presentation String

	public func presentationString(block: BlockNode) -> String {
		return presentationString(backingRange: block.range)
	}

	public func presentationString(backingRange: NSRange) -> String {
		let text = NSMutableString(string: (backingString as NSString).substring(with: backingRange))

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
			text.replaceCharacters(in: range, with: "")
			offset += range.length
		}

		return text as String
	}


	// MARK: - Private

	fileprivate static func present(backingString: String, blocks: [BlockNode]) -> (String, [NSRange], [NSRange]) {
		let text = backingString as NSString

		var presentationString = ""
		var hiddenRanges = [NSRange]()
		var blockRanges = [NSRange]()
		var location: Int = 0

		for (i, block) in blocks.enumerated() {
			let isLast = i == blocks.count - 1
			var blockRange = NSRange(location: location, length: 0)
			hiddenRanges += block.hiddenRanges

			if block is Attachable {
				// Special case for attachments
				#if os(watchOS)
					presentationString += "🖼"
				#else
					presentationString += String(Character(UnicodeScalar(NSAttachmentCharacter)!))
				#endif

				location += 1
			} else {
				// Get the raw text of the line
				let line = NSMutableString(string: text.substring(with: block.range))

				// Remove hidden ranges
				var offset = block.range.location
				for range in block.hiddenRanges {
					line.replaceCharacters(in: NSRange(location: range.location - offset, length: range.length), with: "")
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
