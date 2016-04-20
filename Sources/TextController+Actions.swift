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
		print("[CanvasText] TODO: Insert line after")
	}
	
	public func insertLineBefore() {
		print("[CanvasText] TODO: Insert line before")
	}
}
