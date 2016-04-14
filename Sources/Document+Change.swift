//
//  Document+Diff.swift
//  CanvasNative
//
//  Created by Sam Soffes on 4/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

typealias BlockChange = (range: Range<Int>, replacement: [BlockNode])


struct StringChange {

	// MARK: - Properties

	let range: NSRange
	let replacement: String


	// MARK: - Initializers

	init(range: Range<Int>, replacement: String) {
		self.range = NSRange(range)
		self.replacement = replacement
	}

	init(range: NSRange, replacement: String) {
		self.range = range
		self.replacement = replacement
	}
}


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
		let blockChange = diff(before.blocks, after.blocks) { lhs, rhs in
			if lhs.dynamicType != rhs.dynamicType {
				return false
			}

			return lhs.contentInString(before.backingString) == rhs.contentInString(after.backingString)
		}

		// Calculate presentation change
		let presentationStringChange: StringChange? = diff(before.presentationString, after.presentationString).flatMap(StringChange.init)

		return DocumentChange(
			before: before,
			after: after,
			blockChange: blockChange,
			backingStringChange: backingStringChange,
			presentationStringChange: presentationStringChange
		)
	}
}
