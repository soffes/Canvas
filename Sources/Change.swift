//
//  Change.swift
//  CanvasNative
//
//  Created by Sam Soffes on 4/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

struct BlockChange {

	// MARK: - Properties

	let range: NSRange
	let replacement: [BlockNode]


	// MARK: - Initializers

	init(range: Range<Int>, replacement: [BlockNode]) {
		self.range = NSRange(location: range.startIndex, length: range.count - 1)
		self.replacement = replacement
	}

	init(range: NSRange, replacement: [BlockNode]) {
		self.range = range
		self.replacement = replacement
	}
}


struct StringChange {

	// MARK: - Properties

	let range: NSRange
	let replacement: String


	// MARK: - Initializers

	init(range: Range<Int>, replacement: String) {
		self.range = NSRange(location: range.startIndex, length: range.count - 1)
		self.replacement = replacement
	}

	init(range: NSRange, replacement: String) {
		self.range = range
		self.replacement = replacement
	}
}
