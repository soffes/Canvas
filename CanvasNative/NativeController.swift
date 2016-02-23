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
		let parsedBlocks = Parser.parse(string: text, range: invalidRange)

		let newBlocks: [BlockNode]

		// Overlapping range
		if let blockRange = blockRangeForCharacterRange(invalidRange) {
			let updatedBlocks = [BlockNode](blocks[blockRange])

			var workingBlocks = blocks

			// Replace blocks
			workingBlocks.replaceRange(blockRange, with: parsedBlocks)

			for i in blockRange {
				let before = workingBlocks[i]
				let after = workingBlocks[i]
				delegate?.nativeController(self, didReplaceContentForBlock: before, atIndex: UInt(i), withBlock: after)
			}

			// TODO: Currently add and remove are not supported

			// After updated blocks
			let afterDelta = Int(lengthOfBlocks(updatedBlocks)) - Int(lengthOfBlocks(parsedBlocks))
			let indexOffset = parsedBlocks.count - blockRange.count
			let afterRange = (blockRange.endIndex + indexOffset)..<workingBlocks.endIndex

			for i in afterRange {
				let b = workingBlocks[i]
				var block = b
				block.offset(afterDelta)
				workingBlocks[i] = block
				delegate?.nativeController(self, didUpdateLocationForBlock: b, atIndex: UInt(i), withBlock: block)
			}

			newBlocks = workingBlocks
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
}
