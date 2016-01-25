//
//  Color.swift
//  CanvasKit
//
//  Created by Sam Soffes on 1/25/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

/// Portable RGB color.
public struct Color {

	// MARK: - Properties

	public var red: Float
	public var green: Float
	public var blue: Float
	public var alpha: Float

	/// 8-character hex representation (RRGGBBAA)
	public var hex: String {
		return String(Int(red * 255), radix: 16) + String(Int(green * 255), radix: 16) + String(Int(blue * 255), radix: 16) + String(Int(alpha * 255), radix: 16)
	}


	// MARK: - Initializers

	// From https://github.com/soffes/X
	public init?(hex string: String) {
		var hex = string as NSString

		// Remove `#` and `0x`
		if hex.hasPrefix("#") {
			hex = hex.substringFromIndex(1)
		} else if hex.hasPrefix("0x") {
			hex = hex.substringFromIndex(2)
		}

		// Invalid if not 3, 6, or 8 characters
		let length = hex.length
		if length != 3 && length != 6 && length != 8 {
			return nil
		}

		// Make the string 8 characters long for easier parsing
		if length == 3 {
			let r = hex.substringWithRange(NSRange(location: 0, length: 1))
			let g = hex.substringWithRange(NSRange(location: 1, length: 1))
			let b = hex.substringWithRange(NSRange(location: 2, length: 1))
			hex = r + r + g + g + b + b + "ff"
		} else if length == 6 {
			hex = String(hex) + "ff"
		}

		// Convert 2 character strings to CGFloats
		func hexValue(string: String) -> Float {
			let value = Double(strtoul(string, nil, 16))
			return Float(value / 255.0)
		}

		red = hexValue(hex.substringWithRange(NSMakeRange(0, 2)))
		green = hexValue(hex.substringWithRange(NSMakeRange(2, 2)))
		blue = hexValue(hex.substringWithRange(NSMakeRange(4, 2)))
		alpha = hexValue(hex.substringWithRange(NSMakeRange(6, 2)))
	}
}
