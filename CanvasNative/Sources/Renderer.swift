//
//  Renderer.swift
//  CanvasNative
//
//  Created by Sam Soffes on 6/9/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

public protocol Renderer {
	init(document: Document)
	func render() -> String
}
