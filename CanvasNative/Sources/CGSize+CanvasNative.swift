//
//  CGSize+CanvasNative.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/24/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CoreGraphics

extension CGSize {
	var dictionary: [String: Any] {
		return [
			"width": width,
			"height": height
		]
	}
}
