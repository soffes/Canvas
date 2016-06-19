//
//  Font.swift
//  CanvasCore
//
//  Created by Sam Soffes on 11/27/15.
//  Copyright © 2015–2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

public struct Font {

	public enum Weight {
		case regular
		case bold

		var weight: CGFloat {
			switch self {
			case .regular: return UIFontWeightRegular
			case .bold: return UIFontWeightMedium
			}
		}
	}

	public enum Style {
		case regular
		case italic
	}

	public enum Size: UInt {
		case small = 14
		case subtitle = 16
		case body = 18

		var pointSize: CGFloat {
			return CGFloat(rawValue)
		}
	}

	public static func sansSerif(weight weight: Weight = .regular, style: Style = .regular, size: Size = .body) -> UIFont! {
		if style == .italic {
			// TODO: Weight is currently ignored for italic
			return .italicSystemFontOfSize(size.pointSize)
		}

		return .systemFontOfSize(size.pointSize, weight: weight.weight)
	}
}
