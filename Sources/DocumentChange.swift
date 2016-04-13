//
//  DocumentChange.swift
//  CanvasNative
//
//  Created by Sam Soffes on 4/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

struct DocumentChange {

	// MARK: - Properties

	let before: Document
	let after: Document

	let blockChange: BlockChange?
	let backingStringChange: StringChange
	let presentationStringChange: StringChange?


	// MARK: - Initializers

	init(before: Document, after: Document, blockChange: BlockChange?, backingStringChange: StringChange, presentationStringChange: StringChange?) {
		self.before = before
		self.after = after
		self.blockChange = blockChange
		self.backingStringChange = backingStringChange
		self.presentationStringChange = presentationStringChange
	}
}
