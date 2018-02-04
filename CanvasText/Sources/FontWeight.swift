import UIKit

// TODO: Replace with UIFont.Weight?
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
		case .ultraLight:
			return UIFont.Weight.ultraLight.rawValue
		case .thin:
			return UIFont.Weight.thin.rawValue
		case .light:
			return UIFont.Weight.light.rawValue
		case .regular:
			return UIFont.Weight.regular.rawValue
		case .medium:
			return UIFont.Weight.medium.rawValue
		case .semibold:
			return UIFont.Weight.semibold.rawValue
		case .bold:
			return UIFont.Weight.bold.rawValue
		case .heavy:
			return UIFont.Weight.heavy.rawValue
		case .black:
			return UIFont.Weight.black.rawValue
		}
	}

	public var description: String {
		switch self {
		case .ultraLight:
			return "UltraLight"
		case .thin:
			return "Thin"
		case .light:
			return "Light"
		case .regular:
			return "Regular"
		case .medium:
			return "Medium"
		case .semibold:
			return "Semibold"
		case .bold:
			return "Bold"
		case .heavy:
			return "Heavy"
		case .black:
			return "Black"
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
		guard let weight = FontWeight.faces[face] else {
            return nil
        }
		self = weight
	}
}
