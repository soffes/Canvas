//
//  BlockNode.swift
//  CanvasNative
//
//  Created by Sam Soffes on 1/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol BlockNode: Node {
	/// Ranges hidden from visible the presentation string
	var hiddenRanges: [NSRange] { get }

	init?(string: String, range: NSRange)
}
