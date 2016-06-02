//
//  TextStorage.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/4/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

typealias Style = (range: NSRange, attributes: Attributes)

protocol TextStorageDelegate: class {
	func textStorage(textStorage: TextStorage, didReplaceCharactersInRange range: NSRange, withString string: String)
	func textStorageDidProcessEditing(textStorage: TextStorage)
}

class TextStorage: BaseTextStorage {

	// MARK: - Properties

	weak var textController: TextController?
	weak var customDelegate: TextStorageDelegate?

	var isEditing: Bool {
		return editCount > 0
	}

	private var editCount = 0

	private var styles = [Style]()
	private var invalidDisplayRange: NSRange?

	
	// MARK: - NSTextStorage

	override func beginEditing() {
		editCount += 1
		super.beginEditing()
	}

	override func endEditing() {
		editCount -= 1
		super.endEditing()
	}

	override func replaceCharactersInRange(range: NSRange, withString string: String) {
		// Local changes are delegated to the text controller
		customDelegate?.textStorage(self, didReplaceCharactersInRange: range, withString: string)
	}

	override func processEditing() {
		applyStyles()

		super.processEditing()

		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			self?.invalidateLayoutIfNeeded()
		}

		customDelegate?.textStorageDidProcessEditing(self)
	}


	// MARK: - Updating Content

	func actuallyReplaceCharactersInRange(range: NSRange, withString string: String) {
		super.replaceCharactersInRange(range, withString: string)
		
		// Calculate the line range
		let text = self.string as NSString
		var lineRange = range
		lineRange.length = (string as NSString).length
		lineRange = text.lineRangeForRange(lineRange)
		
		// Include the line before
		if lineRange.location > 0 {
			lineRange.location -= 1
			lineRange.length += 1
		}
		
		invalidDisplayRange = lineRange
	}


	// MARK: - Styles

	func addStyles(styles: [Style]) {
		self.styles += styles
	}

	func applyStyles() {
		guard !styles.isEmpty else { return }

		for style in styles {
			if style.range.max > storage.length || style.range.length < 0 {
				print("WARNING: Invalid style: \(style.range)")
				continue
			}

			storage.setAttributes(style.attributes, range: style.range)
			edited(.EditedAttributes, range: style.range, changeInLength: 0)
		}

		styles.removeAll()
	}


	// MARK: - Layout

	func invalidRange(range: NSRange) {
		invalidDisplayRange = invalidDisplayRange.flatMap { $0.union(range) } ?? range
	}

	func invalidateLayoutIfNeeded() {
		guard var range = invalidDisplayRange else { return }

		range.length = min(length - range.location, range.length)

		for layoutManager in layoutManagers {
			layoutManager.ensureGlyphsForCharacterRange(range)
			layoutManager.invalidateLayoutForCharacterRange(range, actualCharacterRange: nil)
		}

		self.invalidDisplayRange = nil
	}
}
