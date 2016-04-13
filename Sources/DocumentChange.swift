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

	let blockChanges: [BlockChange]
	let backingStringChange: StringChange
	let presentationStringChange: StringChange?


	// MARK: - Initializers

	init(before: Document, after: Document, blockChanges: [BlockChange], backingStringChange: StringChange, presentationStringChange: StringChange?) {
		self.before = before
		self.after = after
		self.blockChanges = blockChanges
		self.backingStringChange = backingStringChange
		self.presentationStringChange = presentationStringChange
	}
}
