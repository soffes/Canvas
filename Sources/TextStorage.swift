//
//  TextStorage.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/4/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

protocol TextStorageDelegate: class {
	func textStorage(textStorage: TextStorage, didReplaceCharactersInRange range: NSRange, withString string: String)
}

class TextStorage: BaseTextStorage {

	// MARK: - Properties

	weak var textController: TextController?
	weak var replacementDelegate: TextStorageDelegate?


	// MARK: - Updating Content

	func actuallyReplaceCharactersInRange(range: NSRange, withString string: String) {
		super.replaceCharactersInRange(range, withString: string)
	}


	// MARK: - NSTextStorage

	override func replaceCharactersInRange(range: NSRange, withString string: String) {
		// Local changes are delegated to the text controller
		replacementDelegate?.textStorage(self, didReplaceCharactersInRange: range, withString: string)
	}
}
