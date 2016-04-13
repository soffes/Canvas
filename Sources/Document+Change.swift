//
//  Document+Diff.swift
//  CanvasNative
//
//  Created by Sam Soffes on 4/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

extension Document {
	func replaceCharactersInRange(range: NSRange, withString string: String) -> DocumentChange {
		let before = self

		// Calculate new backing string
		let text = NSMutableString(string: before.backingString)
		text.replaceCharactersInRange(range, withString: string)
		let backingStringChange = StringChange(range: range, string: string)

		// Create new document
		let after = Document(backingString: text as String)

		// Calculate block changes
		var blockChanges = [BlockChange]()
		for (i, afterBlock) in after.blocks.enumerate() {
			// Out of bounds. Insert.
			if i >= before.blocks.count {
				blockChanges.append(.Insert(block: afterBlock, index: i))
				continue
			}

			let beforeBlock = before.blocks[i]

			// No change
			if beforeBlock.contentInString(before.backingString) == afterBlock.contentInString(after.backingString) {
				continue
			} else {
				// Updated content
				if beforeBlock.dynamicType == afterBlock.dynamicType {
					blockChanges.append(.Replace(before: beforeBlock, index: i, after: afterBlock))
				}

				// Changed type
				else {
					blockChanges += [
						.Remove(block: beforeBlock, index: i),
						.Insert(block: afterBlock, index: i)
					]
				}
			}
		}

		// TODO: Calculate updates

		// Calculate presentation change
		let result = diff(before.presentationString, after.presentationString)
		let presentationStringChange: StringChange? = result.flatMap(StringChange.init)

		return DocumentChange(
			before: before,
			after: after,
			blockChanges: blockChanges,
			backingStringChange: backingStringChange,
			presentationStringChange: presentationStringChange
		)
	}
}
