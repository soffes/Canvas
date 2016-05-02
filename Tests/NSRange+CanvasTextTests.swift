//
//  NSRange+CanvasTextTests.swift
//  CanvasText
//
//  Created by Sam Soffes on 5/2/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

extension NSRange: Equatable {
	static let zero = NSRange(location: 0, length: 0)
}

public func ==(lhs: NSRange, rhs: NSRange) -> Bool {
	return NSEqualRanges(lhs, rhs)
}
