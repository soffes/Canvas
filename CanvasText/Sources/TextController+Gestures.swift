//
//  TextController+Gestures.swift
//  CanvasText
//
//  Created by Sam Soffes on 5/3/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasNative

extension TextController {
	public func increaseBlockLevel(block block: BlockNode) {
		// Convert paragraph to unordered list
		if block is Paragraph {
			let string = ChecklistItem.nativeRepresentation()
			var range = block.visibleRange
			range.length = 0
			edit(backingRange: range, replacement: string)
			return
		}

		// Convert checklist to unordered list
		if let block = block as? ChecklistItem {
			let string = UnorderedListItem.nativeRepresentation()
			edit(backingRange: block.nativePrefixRange, replacement: string)
			return
		}

		// Lists
		if let block = block as? Listable {
			// Increment indentation
			let newIndentation = block.indentation.successor

			// Already at its maximum indentation
			if newIndentation == block.indentation {
				return
			}

			let string = newIndentation.string
			edit(backingRange: block.indentationRange, replacement: string)
			return
		}

		// Decrease headings
		if let block = block as? Heading {
			// Convert to Paragraph
			if block.level == .three {
				edit(backingRange: block.leadingDelimiterRange, replacement: "")
				return
			}

			let string = Heading.nativeRepresentation(level: block.level.successor)
			edit(backingRange: block.leadingDelimiterRange, replacement: string)
			return
		}
	}

	public func decreaseBlockLevel(block block: BlockNode) {
		// Lists
		if let block = block as? Listable {
			// Convert checklist to paragraph
			if let block = block as? ChecklistItem {
				edit(backingRange: block.nativePrefixRange, replacement: "")
				return
			}

			// Convert unordered list to checklist
			let newIndentation = block.indentation.predecessor
			if newIndentation == block.indentation {
				let string = ChecklistItem.nativeRepresentation()
				edit(backingRange: block.nativePrefixRange, replacement: string)
				return
			}

			// Decrement indentation
			let string = newIndentation.string
			edit(backingRange: block.indentationRange, replacement: string)
			return
		}

		// Convert Paragraph to Heading
		if block is Paragraph {
			let string = Heading.nativeRepresentation(level: .three)
			var range = block.visibleRange
			range.length = 0
			edit(backingRange: range, replacement: string)
			return
		}

		// Increase Heading level
		if let block = block as? Heading where block.level != .one {
			let string = Heading.nativeRepresentation(level: block.level.predecessor)
			edit(backingRange: block.leadingDelimiterRange, replacement: string)
			return
		}
	}
}
