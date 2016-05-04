//
//  TextController+Actions.swift
//  CanvasText
//
//  Created by Sam Soffes on 4/19/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasNative

extension TextController {
	public func toggleChecked() {
		guard let block = focusedBlock as? ChecklistItem else { return }

		let range = block.stateRange
		let replacement = block.state.opposite.string
		edit(backingRange: range, replacement: replacement)
	}

	public func indent() {
		guard let block = focusedBlock as? Listable where !block.indentation.isMaximum else { return }

		let range = block.indentationRange
		let replacement = block.indentation.successor.string
		edit(backingRange: range, replacement: replacement)
	}

	public func outdent() {
		guard let block = focusedBlock as? Listable where !block.indentation.isMinimum else { return }

		let range = block.indentationRange
		let replacement = block.indentation.predecessor.string
		edit(backingRange: range, replacement: replacement)
	}

	public func bold() {
		print("[CanvasText] TODO: Bold")
	}

	public func italic() {
		print("[CanvasText] TODO: Italic")
	}

	public func inlineCode() {
		print("[CanvasText] TODO: Inline code")
	}
	
	public func insertLineAfter() {
		guard let selection = presentationSelectedRange else { return }
		
		let text = documentController.document.presentationString as NSString
		let lineRange = text.lineRangeForRange(selection)
		let adjust = text.substringWithRange(NSRange(location: lineRange.max - 1, length: 1)) == "\n" ? 1 : 0
		var range = NSRange(location: lineRange.max - adjust, length: 0)
		textStorage.replaceCharactersInRange(range, withString: "\n")

		range.location += 1
		setPresentationSelectedRange(range, updateTextView: true)
	}
	
	public func insertLineBefore() {
		guard let selection = presentationSelectedRange else { return }
		
		let text = documentController.document.presentationString as NSString
		let lineRange = text.lineRangeForRange(selection)
		
		// Don't insert lines above the title
		if lineRange.location == 0 {
			return
		}
		
		var range = NSRange(location: lineRange.location - 1, length: 0)
		textStorage.replaceCharactersInRange(range, withString: "\n")

		range.location += 1
		setPresentationSelectedRange(range, updateTextView: true)
	}
	
	public func deleteLine() {
		guard let selection = presentationSelectedRange else { return }
		
		let text = documentController.document.presentationString as NSString
		var range = text.lineRangeForRange(selection)
		textStorage.replaceCharactersInRange(range, withString: "")

		range.length = 0
		setPresentationSelectedRange(range, updateTextView: true)
	}
}
