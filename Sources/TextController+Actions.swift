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
		guard let block = focusedBlock as? ChecklistItem
		else { return }

		let range = block.stateRange
		let replacement = block.state.opposite.string
		edit(backingRange: range, replacement: replacement)
	}
}
