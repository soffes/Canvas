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
		// Calculate new backing string
		let text = NSMutableString(string: self.backingString)
		text.replaceCharactersInRange(range, withString: string)
		let backingStringChange = StringChange(range: range, string: string)

		// Create new document
		let after = Document(backingString: text as String)

		// TODO: Calculate block changes
		let blockChanges = [BlockChange]()

		// Calculate presentation change
		let result = diff(presentationString, after.presentationString)
		let presentationStringChange: StringChange? = result.flatMap(StringChange.init)

		return DocumentChange(
			before: self,
			after: after,
			blockChanges: blockChanges,
			backingStringChange: backingStringChange,
			presentationStringChange: presentationStringChange
		)
	}
}
