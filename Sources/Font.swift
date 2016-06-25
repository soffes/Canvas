//
//  Font.swift
//  CanvasCore
//
//  Created by Sam Soffes on 11/27/15.
//  Copyright © 2015–2016 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import X

public struct Font {

	public enum Weight {
		case regular
		case bold

		var weight: CGFloat {
			switch self {
			case .regular:
				#if os(OSX)
					return NSFontWeightRegular
				#else
					return UIFontWeightRegular
				#endif
			case .bold:
				#if os(OSX)
					return NSFontWeightMedium
				#else
					return UIFontWeightMedium
				#endif
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
		case heading = 22

		var pointSize: CGFloat {
			return CGFloat(rawValue)
		}
	}

	public static func sansSerif(weight weight: Weight = .regular, style: Style = .regular, size: Size = .body) -> X.Font! {
		// TODO: Italic isn't supported on macOS yet
		#if !os(OSX)
			if style == .italic {
				// TODO: Weight is currently ignored for italic
				return X.Font.italicSystemFontOfSize(size.pointSize)
			}
		#endif

		return X.Font.systemFontOfSize(size.pointSize, weight: weight.weight)
	}
}
