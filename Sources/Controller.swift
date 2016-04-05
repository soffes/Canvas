//
//  Controller.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/18/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public final class Controller {

	// MARK: - Types

	private enum Message {
		case Insert(block: BlockNode, index: Int)
		case Remove(block: BlockNode, index: Int)
		case Replace(before: BlockNode, index: Int, after: BlockNode)
		case Update(before: BlockNode, index: Int, after: BlockNode)
	}


	// MARK: - Properties

	public weak var delegate: ControllerDelegate?

	public private(set) var blocks = [BlockNode]() {
		didSet {
			updateBlockPresentationLocations()
		}
	}

	private var blockPresentationLocations = [Int]()

	public var string: String {
		get {
			return text as String
		}

		set {
			replaceCharactersInRange(NSRange(location: 0, length: length), withString: newValue)
		}
	}

	public var length: Int {
		return text.length
	}

	private let text: NSMutableString = ""


	// MARK: - Initializers

	public init(string: String? = nil, delegate: ControllerDelegate? = nil) {
		self.delegate = delegate

		if let string = string where !string.isEmpty {
			self.string = string
		}
	}


	// MARK: - Changing Text

	public func replaceCharactersInRange(range: NSRange, withString inString: String) {
		let string = inString as NSString

		// Notify the delegate we're beginning
		delegate?.controllerWillUpdateNodes(self)

		// Calculate blocks changed by the edit
		let blockRange = blockRangeForCharacterRange(range, string: string as String)

		// Update the text representation
		text.replaceCharactersInRange(range, withString: string as String)

		// Get the range of the replacement in the presentation string
		let displayRange = presentationRange(backingRange: range, blocks: blocks)

		// Reparse the invalid range of document
		let invalidRange = parseRangeForRange(NSRange(location: range.location, length: string.length))
		let shouldParse = invalidRange.length > 0
		let parsedBlocks = shouldParse ? Parser.parse(text, range: invalidRange) : []
		let (workingBlocks, messages) = applyParsedBlocks(parsedBlocks, parseRange: invalidRange, blockRange: blockRange)

		// Calculate message for presentation replacement
		let replacement: String?
		if inString.isEmpty {
			// If we're deleting, this is easy
			replacement = ""
		} else {
			// Get the replacement string from the updated presentation string
			let editRange = NSRange(location: range.location, length: string.length)
			replacement = presentationString(backingRange: editRange, blocks: workingBlocks)
		}

		// Update the blocks
		blocks = workingBlocks

		// Notify the delegate of a text change
		if let replacement = replacement {
			delegate?.controller(self, didReplaceCharactersInPresentationStringInRange: displayRange, withString: replacement)
		}

		// Send the rest of the messages
		messages.forEach(sendDelegateMessage)

		// Notify the delegate we're done
		delegate?.controllerDidUpdateNodes(self)
	}


	// MARK: - Applying Changes to the Tree

	private func applyParsedBlocks(parsedBlocks: [BlockNode], parseRange: NSRange, blockRange: NSRange) -> ([BlockNode], [Message]) {
		// Start to calculate the new blocks
		var workingBlocks = blocks
		var messages = [Message]()

		let afterRange: Range<Int>
		let afterOffset: Int

		let updatedBlocks = [BlockNode](blocks[blockRange.range])

		let blockDelta = parsedBlocks.count - updatedBlocks.count
		var replaced = 0

		// Inserting
		if blockDelta > 0 {
			for i in 0..<blockDelta {
				let block = parsedBlocks[i]
				let index = i + blockRange.location
				workingBlocks.insert(block, atIndex: index)
				replaced += 1
				messages.append(.Insert(block: block, index: index))
			}
		}

		// Deleting
		if blockDelta < 0 {
			for _ in (blockRange.location)..<(blockRange.location - blockDelta) {
				let index = blockRange.location
				let block = workingBlocks[index]
				workingBlocks.removeAtIndex(index)
				messages.append(.Remove(block: block, index: index))
			}
		}

		// Replace the remaining blocks
		for i in replaced..<parsedBlocks.count {
			let after = parsedBlocks[i]
			let index = i + blockRange.location
			let before = workingBlocks[index]
			workingBlocks.removeAtIndex(index)
			workingBlocks.insert(after, atIndex: index)
			messages.append(.Replace(before: before, index: index, after: after))
		}

		afterOffset = Int(characterLengthOfBlocks(parsedBlocks)) - Int(characterLengthOfBlocks(updatedBlocks)) + blockDelta
		afterRange = (blockRange.max + blockDelta)..<workingBlocks.endIndex

		// Update blocks after edit
		let (offsetBlocks, offsetMessages) = self.offsetBlocks(blocks: workingBlocks, blockRange: afterRange, offset: afterOffset)
		workingBlocks = offsetBlocks
		messages += offsetMessages

		// TODO: Recalculate positionable

		return (workingBlocks, messages)
	}

	private func offsetBlocks(blocks blocks: [BlockNode], blockRange: Range<Int>, offset: Int) -> ([BlockNode], [Message]) {
		var workingBlocks = blocks
		var messages = [Message]()

		for index in blockRange {
			let before = workingBlocks[index]
			var after = before
			after.offset(offset)
			workingBlocks[index] = after
			messages.append(.Update(before: before, index: index, after: after))
		}

		return (workingBlocks, messages)
	}


	// MARK: - Range Calculations

	public func presentationRange(backingRange backingRange: NSRange) -> NSRange {
		return presentationRange(backingRange: backingRange, blocks: blocks)
	}

	private func presentationRange(backingRange backingRange: NSRange, blocks: [BlockNode]) -> NSRange {
		var presentationRange = backingRange

		for block in blocks {
			guard let range = (block as? NativePrefixable)?.nativePrefixRange else { continue }

			if range.max <= backingRange.location {
				presentationRange.location -= range.length
			} else if let intersection = backingRange.intersection(range) {
				presentationRange.length -= intersection
			}
		}

		return presentationRange
	}

	public func backingRange(presentationRange presentationRange: NSRange) -> NSRange {
		return backingRange(presentationRange: presentationRange, blocks: blocks)
	}

	private func backingRange(presentationRange presentationRange: NSRange, blocks: [BlockNode]) -> NSRange {
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

		if presentationRange(backingRange: block.visibleRange).contains(presentationLocation) {
			return block
		}

		return nil
	}

	private func parseRangeForRange(range: NSRange) -> NSRange {
		var invalidRange = range

		// Deleting
		if invalidRange.length == 0 {
			// TODO: This needs to return a 0 length if the entire block is removed
			return text.lineRangeForRange(invalidRange)
		}

		let rangeMax = invalidRange.max

		for block in blocks {
			if block.enclosingRange.location >= rangeMax {
				break
			}

			if block.enclosingRange.max - 1 == invalidRange.location {
				invalidRange.location += 1
				invalidRange.length -= 1
				break
			}
		}

		return text.lineRangeForRange(invalidRange)
	}


	// MARK: - Block Calculations

	private func characterLengthOfBlocks(blocks: [BlockNode]) -> UInt {
		return blocks.map { UInt($0.range.length) }.reduce(0, combine: +)
	}

	func blockRangeForCharacterRange(range: NSRange, string: String) -> NSRange {
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
		if !blocks.isEmpty && location == nil && matchingBlocks.isEmpty && !hasNewLinePrefix {
			return NSRange(location: blocks.count - 1, length: 1)
		}

		// If we didn't find anything, assume we're inserting at the very end.
		var blockRange = NSRange(location: location ?? blocks.endIndex, length: matchingBlocks.count)

		// If we delete the new line in the last block, extend the length if possible.
		if string.isEmpty, let lastNewLine = matchingBlocks.last?.newLineRange where lastNewLine.intersection(range) == 1 {
			blockRange.length = min(blockRange.length + 1, blocks.count - blockRange.location)
		}

		return blockRange
	}

	func presentationString(backingRange backingRange: NSRange) -> String? {
		return presentationString(backingRange: backingRange, blocks: blocks)
	}

	private func presentationString(backingRange backingRange: NSRange, blocks: [BlockNode]) -> String? {
		var output = ""

		for block in blocks {
			if block.enclosingRange.max < backingRange.location {
				continue
			}

			if block.enclosingRange.location > backingRange.max {
				break
			}

			let content = block.contentInString(string)
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

	private func updateBlockPresentationLocations() {
		var offset = 0
		var presentationLocations = [Int]()

		for block in blocks {
			if let range = (block as? NativePrefixable)?.nativePrefixRange {
				offset += range.length
			}

			presentationLocations.append(block.visibleRange.location - offset)
		}

		blockPresentationLocations = presentationLocations
	}


	// MARK: - Delegate Calls

	private func sendDelegateMessage(message: Message) {
		switch message {
		case .Insert(let block, let index):
			delegate?.controller(self, didInsertBlock: block, atIndex: index)
		case .Remove(let block, let index):
			delegate?.controller(self, didRemoveBlock: block, atIndex: index)
		case .Replace(let before, let index, let after):
			if before.dynamicType == after.dynamicType {
				delegate?.controller(self, didReplaceContentForBlock: before, atIndex: index, withBlock: after)
			} else {
				delegate?.controller(self, didRemoveBlock: before, atIndex: index)
				delegate?.controller(self, didInsertBlock: after, atIndex: index)
			}
		case .Update(let before, let index, let after):
			delegate?.controller(self, didUpdateLocationForBlock: before, atIndex: index, withBlock: after)
		}
	}
}
