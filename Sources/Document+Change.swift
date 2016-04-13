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
		let backingStringChange = StringChange(range: range, replacement: string)

		// Create new document
		let after = Document(backingString: text as String)

		// Calculate block changes
		let blockChange = diff(before.blocks, after.blocks, compare: compareBlock).flatMap(BlockChange.init)

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
