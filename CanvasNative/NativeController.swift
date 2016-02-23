//
//  NativeController.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/18/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

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


// - [ ] Insert
// - [ ] Delete
// - [ ] Change type
// - [ ] Positionable
public final class NativeController {

	// MARK: - Properties

	public weak var delegate: NativeControllerDelegate?

	public private(set) var blocks = [BlockNode]()

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

		delegate?.nativeControllerWillUpdateNodes(self)

		// Calculate the range we need to invalidate
		let invalidRange = text.lineRangeForRange(range)

		// Update the text representation
		text.replaceCharactersInRange(range, withString: string)

		// Reparse the invalid range of document
		let parseRange = NSRange(location: invalidRange.location, length: min(text.length, invalidRange.length + (string as NSString).length))
		let parsedBlocks = Parser.parse(string: text, range: parseRange)

		let newBlocks: [BlockNode]

		// Overlapping range
		if let blockRange = blockRangeForCharacterRange(invalidRange) {
			let updatedBlocks = [BlockNode](blocks[blockRange])
			let indexOffset = parsedBlocks.count - blockRange.count

			var workingBlocks = blocks

			// Update blocks
			workingBlocks.replaceRange(blockRange, with: parsedBlocks)

			// Replacing
			for index in blockRange {
				didReplace(before: blocks[index + indexOffset], index: index, after: workingBlocks[index])
			}

			if blockRange.endIndex < blockRange.startIndex + parsedBlocks.count {
				for index in blockRange.endIndex..<(blockRange.startIndex + parsedBlocks.count) {
					let block = parsedBlocks[index - blockRange.endIndex]
					workingBlocks.insert(block, atIndex: index)
					delegate?.nativeController(self, didInsertBlock: block, atIndex: UInt(index))
				}
			}

			// Update blocks after edit
			let afterDelta = Int(lengthOfBlocks(parsedBlocks)) - Int(lengthOfBlocks(updatedBlocks)) + indexOffset
			let afterRange = (blockRange.endIndex + indexOffset)..<workingBlocks.endIndex

			for index in afterRange {
				let before = workingBlocks[index]
				var after = before
				after.offset(afterDelta)
				workingBlocks[index] = after
				didUpdate(before: before, index: index, after: after)
			}

			newBlocks = workingBlocks

			// TODO: Recalculate positionable
		}

		// Non-overlapping range. Replace blocks (not totally sure this is correct)
		else {
			newBlocks = parsedBlocks

			for (i, block) in newBlocks.enumerate() {
				delegate?.nativeController(self, didInsertBlock: block, atIndex: UInt(i))
			}
		}

		blocks = newBlocks

		delegate?.nativeControllerDidUpdateNodes(self)
	}


	// MARK: - Private

	private func lengthOfBlocks(blocks: [BlockNode]) -> UInt {
		return blocks.map { UInt($0.range.length) }.reduce(0, combine: +)
	}

	private func blockRangeForCharacterRange(range: NSRange) -> Range<Int>? {
		let location = range.location
		let max = NSMaxRange(range)

		var start: Int?
		var end: Int?

		for (i, block) in blocks.enumerate() {
			if block.range.location >= max {
				break
			}

			// If the index is in range, add it to the output
			if block.range.location >= location && block.range.location < max {
				if start == nil {
					start = i
				}

				end = i
			}
		}

		guard let rangeStart = start, rangeEnd = end else { return nil }
		return rangeStart...rangeEnd
	}

	private func didReplace(before before: BlockNode, index: Int, after: BlockNode) {
		let i = UInt(index)

		if before.dynamicType == after.dynamicType {
			delegate?.nativeController(self, didReplaceContentForBlock: before, atIndex: i, withBlock: after)
			return
		}

		delegate?.nativeController(self, didRemoveBlock: before, atIndex: i)
		delegate?.nativeController(self, didInsertBlock: after, atIndex: i)
	}

	private func didUpdate(before before: BlockNode, index: Int, after: BlockNode) {
		delegate?.nativeController(self, didUpdateLocationForBlock: before, atIndex: UInt(index), withBlock: after)
	}
}
