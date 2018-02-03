#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import X

public struct Font {

	public enum Weight {
		case regular
		case medium

		// TODO: macOS support. We should unify this with CanvasText’s version of this.
		var weight: UIFont.Weight {
			switch self {
			case .regular:
				return .regular
			case .medium:
				return .medium
			}
		}
	}

	public enum Style {
		case regular
		case italic
	}

	public enum Size: UInt {
		case small = 14
		case body = 17

		var pointSize: CGFloat {
			return CGFloat(rawValue)
		}
	}

	public static func sansSerif(size: Size = .body, weight: Weight = .regular, style: Style = .regular) -> X.Font! {
		// TODO: Italic isn't supported on macOS yet
		#if !os(OSX)
			if style == .italic {
				// TODO: Weight is currently ignored for italic
				return X.Font.italicSystemFont(ofSize: size.pointSize)
			}
		#endif

		return X.Font.systemFont(ofSize: size.pointSize, weight: weight.weight)
	}
}
