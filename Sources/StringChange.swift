//
//  StringChange.swift
//  CanvasNative
//
//  Created by Sam Soffes on 4/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

struct StringChange {

	// MARK: - Properties

	let range: NSRange
	let string: String


	// MARK: - Initializers

	init(range: Range<Int>, string: String) {
		self.range = NSRange(location: range.startIndex, length: range.endIndex - range.startIndex)
		self.string = string
	}

	init(range: NSRange, string: String) {
		self.range = range
		self.string = string
	}
}
