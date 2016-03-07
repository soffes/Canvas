//
//  TextStorage.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/4/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

public class TextStorage: BaseTextStorage {

	// MARK: - Properties

	weak var textController: TextController?


	// MARK: - NSTextStorage

	public override func replaceCharactersInRange(range: NSRange, withString string: String) {
		super.replaceCharactersInRange(range, withString: string)

		guard let theme = textController?.theme else { return }
		let attributes = [
			NSFontAttributeName: theme.fontOfSize(theme.fontSize),
			NSForegroundColorAttributeName: theme.foregroundColor
		]
		let editedRange = NSRange(location: range.location, length: (string as NSString).length - range.length)
		storage.setAttributes(attributes, range: editedRange)
		edited(.EditedAttributes, range: editedRange, changeInLength: 0)
	}
}
