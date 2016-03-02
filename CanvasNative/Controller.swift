//
//  Controller.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/18/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol ControllerDelegate: class {
	func controllerWillUpdateNodes(controller: Controller)

	func controller(controller: Controller, didInsertBlock block: BlockNode, atIndex index: Int)

	func controller(controller: Controller, didRemoveBlock block: BlockNode, atIndex index: Int)

	// The block's content changed.
	func controller(controller: Controller, didReplaceContentForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode)

	// The block's metadata changed.
	func controller(controller: Controller, didUpdateLocationForBlock before: BlockNode, atIndex index: Int, withBlock after: BlockNode)

	func controllerDidUpdateNodes(controller: Controller)
}


public final class Controller {

	// MARK: - Properties

	public weak var delegate: ControllerDelegate?

	public private(set) var blocks = [BlockNode]()

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

		if let string = string {
			self.string = string
		}
	}


	// MARK: - Changing Text

	public func replaceCharactersInRange(range: NSRange, withString string: String) {
		// Notify the delegate we're beginning
		willUpdate()

		// Calculate blocks changed by the edit
		let blockRange = blockRangeForCharacterRange(range, string: string)

		// Update the text representation
		text.replaceCharactersInRange(range, withString: string as String)

		// Reparse the invalid range of document
		let invalidRange = parseRangeForRange(NSRange(location: range.location, length: (string as NSString).length))
		let parsedBlocks = invalidRange.length == 0 ? [] : Parser.parse(text, range: invalidRange)
		blocks = applyParsedBlocks(parsedBlocks, parseRange: invalidRange, blockRange: blockRange)

		// Notify the delegate we're done
		didUpdate()
	}


	// MARK: - Applying Changes to the Tree

	private func applyParsedBlocks(parsedBlocks: [BlockNode], parseRange: NSRange, blockRange: NSRange) -> [BlockNode] {
		// Start to calculate the new blocks
		var workingBlocks = blocks

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
				didInsert(block: block, index: index)
			}
		}

		// Deleting
		if blockDelta < 0 {
			for _ in (blockRange.location)..<(blockRange.location - blockDelta) {
				let index = blockRange.location
				let block = workingBlocks[index]
				workingBlocks.removeAtIndex(index)
				didRemove(block: block, index: index)
			}
		}

		// Replace the remaining blocks
		for i in replaced..<parsedBlocks.count {
			let after = parsedBlocks[i]
			let index = i + blockRange.location
			let before = workingBlocks[index]
			workingBlocks.removeAtIndex(index)
			workingBlocks.insert(after, atIndex: index)
			didReplace(before: before, index: index, after: after)
		}

		afterOffset = Int(characterLengthOfBlocks(parsedBlocks)) - Int(characterLengthOfBlocks(updatedBlocks)) + blockDelta
		afterRange = (blockRange.max + blockDelta)..<workingBlocks.endIndex

		// Update blocks after edit
		workingBlocks = offsetBlocks(blocks: workingBlocks, blockRange: afterRange, offset: afterOffset)

		// TODO: Recalculate positionable

		return workingBlocks
	}

	private func offsetBlocks(blocks blocks: [BlockNode], blockRange: Range<Int>, offset: Int) -> [BlockNode] {
		var workingBlocks = blocks

		for index in blockRange {
			let before = workingBlocks[index]
			var after = before
			after.offset(offset)
			workingBlocks[index] = after
			didUpdate(before: before, index: index, after: after)
		}

		return workingBlocks
	}


	// MARK: - Range Calculations

	private func parseRangeForRange(range: NSRange) -> NSRange {
		var invalidRange = range

		if invalidRange.length == 0 {
			return invalidRange
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
		var length = 0

		let hasNewLinePrefix = string.hasPrefix("\n")

		for (i, block) in blocks.enumerate() {
			if block.enclosingRange.intersection(range) != nil || block.enclosingRange.max == range.location && hasNewLinePrefix {
				// Detect inserting at the end of a line vs inserting a new block
				if block.newLineRange != nil && range.location == block.range.max && hasNewLinePrefix {
					return NSRange(location: min(i + 1, blocks.endIndex), length: 0)
				}

				// Start if we haven't already
				if location == nil {
					location = i
				}

				// Increment the length
				length += 1
			} else if location != nil {
				// This block didn't match and we've already started, so end the range.
				break
			}
		}

		// If we didn't find anything, assume we're inserting at the very end.
		guard let loc = location else { return NSRange(location: blocks.endIndex, length: 0) }

		// Return the range
		return NSRange(location: loc, length: length)
	}


	// MARK: - Delegate Calls

	private func willUpdate() {
		delegate?.controllerWillUpdateNodes(self)
	}

	private func didUpdate() {
		delegate?.controllerDidUpdateNodes(self)
	}

	private func didInsert(block block: BlockNode, index: Int) {
		delegate?.controller(self, didInsertBlock: block, atIndex: index)
	}

	private func didRemove(block block: BlockNode, index: Int) {
		delegate?.controller(self, didRemoveBlock: block, atIndex: index)
	}

	private func didReplace(before before: BlockNode, index: Int, after: BlockNode) {
		if before.dynamicType == after.dynamicType {
			delegate?.controller(self, didReplaceContentForBlock: before, atIndex: index, withBlock: after)
			return
		}

		didRemove(block: before, index: index)
		didInsert(block: after, index: index)
	}

	private func didUpdate(before before: BlockNode, index: Int, after: BlockNode) {
		delegate?.controller(self, didUpdateLocationForBlock: before, atIndex: index, withBlock: after)
	}
}
