//
//  XCTestCase+CanvasNativeTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 3/10/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

extension XCTest {
	func parse(_ string: String) -> [NSDictionary] {
		return Parser.parse(string).map { $0.dictionary as NSDictionary }
	}

	func blockTypes(_ string: String) -> [String] {
		return Parser.parse(string).map { String(describing: $0) }
	}
}
