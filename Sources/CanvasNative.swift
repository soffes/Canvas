//
//  CanvasNative.swift
//  CanvasNative
//
//  Created by Sam Soffes on 5/10/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

public struct CanvasNative {
	/// The version of Canvas Native this library can parse.
	public static let supportedNativeVersion = Set<String>(["0.0.0", "0.0.1"])

	public static func supports(nativeVersion nativeVersion: String) -> Bool {
		return supportedNativeVersion.contains(nativeVersion)
	}
}
