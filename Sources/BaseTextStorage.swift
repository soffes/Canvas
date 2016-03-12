//
//  BaseTextContainer.swift
//  CanvasText
//
//  Created by Sam Soffes on 2/16/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

/// Concrete text storage intended to be subclassed.
public class BaseTextStorage: NSTextStorage {

	// MARK: - Properties

	let storage = NSMutableAttributedString()


	// MARK: - NSTextStorage

	public override var string: String {
		return storage.string
	}

	public override func attributesAtIndex(location: Int, effectiveRange: NSRangePointer) -> [String : AnyObject] {
		return storage.attributesAtIndex(location, effectiveRange: effectiveRange)
	}

	public override func replaceCharactersInRange(range: NSRange, withString string: String) {
		storage.replaceCharactersInRange(range, withString: string)

		let stringLength = (string as NSString).length

		let change = stringLength - range.length
		edited(.EditedCharacters, range: range, changeInLength: change)
	}

	public override func setAttributes(attributes: [String : AnyObject]?, range: NSRange) {
		beginEditing()

		storage.setAttributes(attributes, range: range)

		edited(.EditedAttributes, range: range, changeInLength: 0)

		endEditing()
	}
}
