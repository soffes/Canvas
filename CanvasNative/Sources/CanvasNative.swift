//
//  CanvasNative.swift
//  CanvasNative
//
//  Created by Sam Soffes on 5/10/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

/// The version of Canvas Native this library can parse.
let supportedNativeVersion = Set<String>(["0.0.0", "0.0.1", "0.1.0"])

/// Is a given Canvas Native version supported?
public func supports(nativeVersion: String) -> Bool {
	return supportedNativeVersion.contains(nativeVersion)
}
