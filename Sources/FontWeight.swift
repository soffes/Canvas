//
//  File.swift
//  CanvasText
//
//  Created by Sam Soffes on 7/1/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

public enum FontWeight: CustomStringConvertible {
	case UltraLight
	case Thin
	case Light
	case Regular
	case Medium
	case Semibold
	case Bold
	case Heavy
	case Black

	public var fontWeight: CGFloat {
		switch self {
		case .UltraLight: return UIFontWeightUltraLight
		case .Thin: return UIFontWeightThin
		case .Light: return UIFontWeightLight
		case .Regular: return UIFontWeightRegular
		case .Medium: return UIFontWeightMedium
		case .Semibold: return UIFontWeightSemibold
		case .Bold: return UIFontWeightBold
		case .Heavy: return UIFontWeightHeavy
		case .Black: return UIFontWeightBlack
		}
	}

	public var description: String {
		switch self {
		case .UltraLight: return "UltraLight"
		case .Thin: return "Thin"
		case .Light: return "Light"
		case .Regular: return "Regular"
		case .Medium: return "Medium"
		case .Semibold: return "Semibold"
		case .Bold: return "Bold"
		case .Heavy: return "Heavy"
		case .Black: return "Black"
		}
	}

	private static let faces: [String: FontWeight] = [
		"UltraLight": .UltraLight,
		"Thin": .Thin,
		"Light": .Light,
		"Regular": .Regular,
		"Medium": .Medium,
		"SemiBold": .Semibold,
		"Bold": .Bold,
		"Heavy": .Heavy,
		"Black": .Black
	]

	init?(face: String) {
		guard let weight = FontWeight.faces[face] else { return nil }
		self = weight
	}
}
