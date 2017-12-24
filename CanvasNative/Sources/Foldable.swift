//
//  Foldable.swift
//  CanvasNative
//
//  Created by Sam Soffes on 1/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol Foldable: Node {
	// Ideally, this is always 1-2 in length.
	var foldableRanges: [NSRange] { get }
}
