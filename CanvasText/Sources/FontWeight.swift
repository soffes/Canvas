//
//  File.swift
//  CanvasText
//
//  Created by Sam Soffes on 7/1/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

public enum FontWeight: CustomStringConvertible {
	case ultraLight
	case thin
	case light
	case regular
	case medium
	case semibold
	case bold
	case heavy
	case black

	public var fontWeight: CGFloat {
		switch self {
		case .ultraLight: return UIFontWeightUltraLight
		case .thin: return UIFontWeightThin
		case .light: return UIFontWeightLight
		case .regular: return UIFontWeightRegular
		case .medium: return UIFontWeightMedium
		case .semibold: return UIFontWeightSemibold
		case .bold: return UIFontWeightBold
		case .heavy: return UIFontWeightHeavy
		case .black: return UIFontWeightBlack
		}
	}

	public var description: String {
		switch self {
		case .ultraLight: return "UltraLight"
		case .thin: return "Thin"
		case .light: return "Light"
		case .regular: return "Regular"
		case .medium: return "Medium"
		case .semibold: return "Semibold"
		case .bold: return "Bold"
		case .heavy: return "Heavy"
		case .black: return "Black"
		}
	}

	private static let faces: [String: FontWeight] = [
		"UltraLight": .ultraLight,
		"Thin": .thin,
		"Light": .light,
		"Regular": .regular,
		"Medium": .medium,
		"SemiBold": .semibold,
		"Bold": .bold,
		"Heavy": .heavy,
		"Black": .black
	]

	init?(face: String) {
		guard let weight = FontWeight.faces[face] else { return nil }
		self = weight
	}
}
