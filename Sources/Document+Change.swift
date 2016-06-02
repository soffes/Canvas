//
//  Document+Diff.swift
//  CanvasNative
//
//  Created by Sam Soffes on 4/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

typealias BlockChange = (range: Range<Int>, replacement: [BlockNode])
typealias StringChange = (range: NSRange, replacement: NSString)


struct DocumentChange {

	// MARK: - Properties

	let before: Document
	let after: Document

	let blockChange: BlockChange?
	let backingStringChange: StringChange
	let presentationStringChange: StringChange?


	// MARK: - Initializers

	init(before: Document, after: Document, blockChange: BlockChange?, backingStringChange: StringChange, presentationStringChange: StringChange?) {
		self.before = before
		self.after = after
		self.blockChange = blockChange
		self.backingStringChange = backingStringChange
		self.presentationStringChange = presentationStringChange
	}
}


extension Document {
	func replaceCharactersInRange(range: NSRange, withString string: String) -> DocumentChange {
		let before = self

		// Calculate new backing string
		let text = NSMutableString(string: before.backingString)
		text.replaceCharactersInRange(range, withString: string)
		let backingStringChange = StringChange(range: range, replacement: string)

		// Create new document
		let after = Document(backingString: text as String)

		// Calculate block changes
		let blockChange = diff(before.blocks, after.blocks) { beforeBlock, afterBlock in
			// If they are different types or have different lengths, they are definitely not equal.
			if beforeBlock.dynamicType != afterBlock.dynamicType || beforeBlock.range.length != afterBlock.range.length {
				return false
			}

			// Check positionable
			if let before = beforeBlock as? Positionable, after = afterBlock as? Positionable where before.position != after.position {
				return false
			}

			// Check code block
			if let before = beforeBlock as? CodeBlock, after = afterBlock as? CodeBlock where before.lineNumber != after.lineNumber {
				return false
			}

			// Check ordered list
			if let before = beforeBlock as? OrderedListItem, after = afterBlock as? OrderedListItem where before.number != after.number {
				return false
			}

			// Compare their native representations
			return (before.backingString as NSString).substringWithRange(beforeBlock.range) == (after.backingString as NSString).substringWithRange(afterBlock.range)
		}

		// Calculate presentation change
		let presentationStringChange = diff(before.presentationString as NSString, after.presentationString as NSString)

		return DocumentChange(
			before: before,
			after: after,
			blockChange: blockChange,
			backingStringChange: backingStringChange,
			presentationStringChange: presentationStringChange
		)
	}
}
