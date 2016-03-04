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
		if fixesAttributesLazily {
			ensureAttributesAreFixedInRange(NSRange(location: location, length: 1))
		}
		return storage.attributesAtIndex(location, effectiveRange: effectiveRange)
	}

	public override func replaceCharactersInRange(range: NSRange, withString string: String) {
		beginEditing()

		storage.replaceCharactersInRange(range, withString: string)

		let stringLength = (string as NSString).length
		var editMask = NSTextStorageEditActions.EditedCharacters
		if fixesAttributesLazily && stringLength > 0 {
			editMask.insert(.EditedAttributes)
		}

		let change = stringLength - range.length
		edited(editMask, range: range, changeInLength: change)

		endEditing()
	}

	public override func setAttributes(attributes: [String : AnyObject]?, range: NSRange) {
		beginEditing()

		storage.setAttributes(attributes, range: range)

		if fixesAttributesLazily {
			ensureAttributesAreFixedInRange(range)
		}

		edited(.EditedAttributes, range: range, changeInLength: 0)

		endEditing()
	}
}
