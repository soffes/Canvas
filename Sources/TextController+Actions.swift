//
//  TextController+Actions.swift
//  CanvasText
//
//  Created by Sam Soffes on 4/19/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasNative

extension TextController {
	public func toggleChecked() {
		guard let blocks = focusedBlocks?.flatMap({ $0 as? ChecklistItem }) else { return }

		let states = Set<ChecklistItem.State>(blocks.map({ $0.state }))
		let newState: ChecklistItem.State

		// Has checked items
		if states.contains(.Checked) {
			// If any are unchecked, check all. If there are no unchecked items, uncheck all.
			newState = states.contains(.Unchecked) ? .Checked : .Unchecked
		} else {
			// Only has unchecked items. Check all.
			newState = .Checked
		}

		for block in blocks {
			// Skip blocks that are the same
			if block.state == newState {
				continue
			}

			// Update block
			let range = block.stateRange
			let replacement = newState.string
			edit(backingRange: range, replacement: replacement)
		}
	}

	public func indent() {
		guard let blocks = focusedBlocks?.flatMap({ $0 as? Listable }) else { return }

		for block in blocks {
			if block.indentation.isMaximum {
				continue
			}

			let range = block.indentationRange
			let replacement = block.indentation.successor.string
			edit(backingRange: range, replacement: replacement)
		}
	}

	public func outdent() {
		guard let blocks = focusedBlocks?.flatMap({ $0 as? Listable }) else { return }

		for block in blocks {
			if block.indentation.isMinimum {
				continue
			}

			let range = block.indentationRange
			let replacement = block.indentation.predecessor.string
			edit(backingRange: range, replacement: replacement)
		}
	}

	public func bold() {
		print("[CanvasText] TODO: Bold")
	}

	public func italic() {
		print("[CanvasText] TODO: Italic")
	}

	public func inlineCode() {
		print("[CanvasText] TODO: Inline code")
	}
	
	public func insertLineAfter() {
		guard let selection = presentationSelectedRange else { return }
		
		let text = currentDocument.presentationString as NSString
		let lineRange = text.lineRangeForRange(selection)
		var range = NSRange(location: lineRange.max, length: 0)

		if text.substringWithRange(NSRange(location: lineRange.max - 1, length: 1)) == "\n" {
			range.location -= 1
		}

		textStorage.replaceCharactersInRange(range, withString: "\n")

		range.location += 1
		setPresentationSelectedRange(range, updateTextView: true)
	}
	
	public func insertLineBefore() {
		guard let selection = presentationSelectedRange else { return }
		
		let text = currentDocument.presentationString as NSString
		let lineRange = text.lineRangeForRange(selection)
		
		// Don't insert lines above the title
		if lineRange.location == 0 {
			return
		}
		
		var range = NSRange(location: lineRange.location - 1, length: 0)

		textStorage.replaceCharactersInRange(range, withString: "\n")

		range.location += 1
		setPresentationSelectedRange(range, updateTextView: true)
	}
	
	public func deleteLine() {
		guard let blocks = focusedBlocks else { return }

		let length = (currentDocument.backingString as NSString).length
		var range = NSRange(location: -1, length: 0)

		for block in blocks {
			if block is Title {
				range = block.visibleRange
				continue
			}

			if range.location == -1 {
				range = block.range
			} else {
				range = range.union(block.range)
			}

			if range.max < length {
				range.length += 1
			}
		}

		if range.length == 0 {
			return
		}

		edit(backingRange: range, replacement: "")
	}

	public func swapLineUp() {
		guard var selection = presentationSelectedRange, let block = focusedBlock where !(block is Title) else { return }

		let document = currentDocument

		// Prevent swapping up to the title
		guard let index = document.indexOf(block: block) where index > 1 else { return }

		let before = document.blocks[index - 1]
		let range = before.range.union(block.range)

		let text = document.backingString as NSString
		let replacement = text.substringWithRange(block.range) + "\n" + text.substringWithRange(before.range)
		edit(backingRange: range, replacement: replacement)

		selection.location -= before.visibleRange.length + 1
		setPresentationSelectedRange(selection, updateTextView: true)
	}

	public func swapLineDown() {
		guard var selection = presentationSelectedRange, let block = focusedBlock where !(block is Title) else { return }

		let document = currentDocument

		// Prevent swapping down the last line
		guard let index = document.indexOf(block: block) where index < document.blocks.count - 1 else { return }

		let after = document.blocks[index + 1]
		let range = after.range.union(block.range)

		let text = document.backingString as NSString
		let replacement = text.substringWithRange(after.range) + "\n" + text.substringWithRange(block.range)
		edit(backingRange: range, replacement: replacement)

		selection.location += after.visibleRange.length + 1
		setPresentationSelectedRange(selection, updateTextView: true)
	}
}
