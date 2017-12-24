//
//  Package.swift
//  CanvasNative
//
//  Created by Sam Soffes on 4/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import PackageDescription

let package = Package(name: "CanvasNative",
	dependencies: [
		.Package(url: "https://github.com/soffes/diff.git", Version(0, 0, 1))
 	]
)
