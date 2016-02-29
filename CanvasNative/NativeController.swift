//
//  NativeController.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/18/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol NativeControllerDelegate: class {
	func nativeControllerWillUpdateNodes(nativeController: NativeController)

	func nativeController(nativeController: NativeController, didInsertBlock block: BlockNode, atIndex index: UInt)

	func nativeController(nativeController: NativeController, didRemoveBlock block: BlockNode, atIndex index: UInt)

	// The block's content changed.
	func nativeController(nativeController: NativeController, didReplaceContentForBlock before: BlockNode, atIndex index: UInt, withBlock after: BlockNode)

	// The block's metadata changed.
	func nativeController(nativeController: NativeController, didUpdateLocationForBlock before: BlockNode, atIndex index: UInt, withBlock after: BlockNode)

	func nativeControllerDidUpdateNodes(nativeController: NativeController)
}


public final class NativeController {

	// MARK: - Properties

	public weak var delegate: NativeControllerDelegate?

	public private(set) var blocks = [BlockNode]()

	public var string: String {
		return text as String
	}

	private let text: NSMutableString = ""


	// MARK: - Initializers

	public init(text: String? = nil, delegate: NativeControllerDelegate? = nil) {
		self.delegate = delegate

		if let text = text {
			replaceCharactersInRange(NSRange(location: 0, length: self.text.length), withString: text)
		}
	}


	// MARK: - Changing Text

	public func replaceCharactersInRange(range: NSRange, withString string: String) {

		// Notify the delegate we're beginning
		willUpdate()

		// Calculate blocks changed by the edit
		let blockRange = blockRangeForCharacterRange(text.lineRangeForRange(range))

		// Update the text representation
		text.replaceCharactersInRange(range, withString: string)

		// Reparse the invalid range of document
		let invalidRange = parseRange(range: range, stringLength: (string as NSString).length)
		let parsedBlocks = invalidRange.length == 0 ? [] : Parser.parse(string: text, range: invalidRange)
		blocks = applyParsedBlocks(parsedBlocks, parseRange: invalidRange, blockRange: blockRange)

		// Notify the delegate we're done
		didUpdate()
	}


	// MARK: - Applying Changes to the Tree

	private func applyParsedBlocks(parsedBlocks: [BlockNode], parseRange: NSRange, blockRange: Range<Int>?) -> [BlockNode] {
		// Start to calculate the new blocks
		var workingBlocks = blocks

		let afterRange: Range<Int>
		let afterOffset: Int

		let updatedBlocks: [BlockNode]

		if let blockRange = blockRange {
			updatedBlocks = [BlockNode](blocks[blockRange])
		} else {
			updatedBlocks = []
		}

		let blockDelta = parsedBlocks.count - (blockRange?.count ?? 0)
		var replaced = 0

		// Inserting
		if blockDelta > 0 {
			for i in 0..<blockDelta {
				let block = parsedBlocks[i]
				let index = i + (blockRange?.startIndex ?? 0)
				workingBlocks.insert(block, atIndex: index)
				replaced += 1
				didInsert(block: block, index: index)
			}
		}

		// Deleting
		if blockDelta < 0, let blockRange = blockRange {
			for i in (blockRange.startIndex)..<(blockRange.startIndex - blockDelta) {
				let block = workingBlocks[i]
				workingBlocks.removeAtIndex(i)
				didRemove(block: block, index: i)
			}
		}

		// Replace the remaining blocks
		if let blockRange = blockRange {
			for i in replaced..<parsedBlocks.count {
				let after = parsedBlocks[i]
				let index = i + blockRange.startIndex
				let before = workingBlocks[index]
				workingBlocks.removeAtIndex(index)
				workingBlocks.insert(after, atIndex: index)
				didReplace(before: before, index: index, after: after)
			}
		}

		afterOffset = Int(characterLengthOfBlocks(parsedBlocks)) - Int(characterLengthOfBlocks(updatedBlocks)) + blockDelta
		afterRange = ((blockRange?.endIndex ?? 0) + blockDelta)..<workingBlocks.endIndex

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

	private func parseRange(range range: NSRange, stringLength: Int) -> NSRange {
		var invalidRange = range
		invalidRange.length = stringLength

		if stringLength == 0 {
			return invalidRange
		}

		let rangeMax = range.max

		for block in blocks {
			if block.enclosingRange.location >= rangeMax {
				break
			}

			if block.enclosingRange.max - 1 == range.location {
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

	private func blockRangeForCharacterRange(range: NSRange) -> Range<Int>? {
		var start: Int?
		var end: Int?

		for (i, block) in blocks.enumerate() {
			if block.enclosingRange.intersection(range) != nil {
				if start == nil {
					start = i
				}
				end = i
			} else if start != nil {
				break
			}
		}

		guard let rangeStart = start, rangeEnd = end else { return nil }
		return rangeStart...rangeEnd
	}


	// MARK: - Delegate Calls

	private func willUpdate() {
		delegate?.nativeControllerWillUpdateNodes(self)
	}

	private func didUpdate() {
		delegate?.nativeControllerDidUpdateNodes(self)
	}

	private func didInsert(block block: BlockNode, index: Int) {
		delegate?.nativeController(self, didInsertBlock: block, atIndex: UInt(index))
	}

	private func didRemove(block block: BlockNode, index: Int) {
		delegate?.nativeController(self, didRemoveBlock: block, atIndex: UInt(index))
	}

	private func didReplace(before before: BlockNode, index: Int, after: BlockNode) {
		if before.dynamicType == after.dynamicType {
			delegate?.nativeController(self, didReplaceContentForBlock: before, atIndex: UInt(index), withBlock: after)
			return
		}

		didRemove(block: before, index: index)
		didInsert(block: after, index: index)
	}

	private func didUpdate(before before: BlockNode, index: Int, after: BlockNode) {
		delegate?.nativeController(self, didUpdateLocationForBlock: before, atIndex: UInt(index), withBlock: after)
	}
}
