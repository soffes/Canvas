import UIKit

public enum TextStyle {
	case title1
	case title2
	case title3
	case headline
	case subheadline
	case body
	case footnote
	case caption1
	case caption2
	case callout

	public var textStyle: UIFont.TextStyle {
		switch self {
		case .title1:
			return .title1
		case .title2:
			return .title2
		case .title3:
			return .title3
		case .headline:
			return .headline
		case .subheadline:
			return .subheadline
		case .body:
			return .body
		case .footnote:
			return .footnote
		case .caption1:
			return .caption1
		case .caption2:
			return .caption2
		case .callout:
			return .callout
		}
	}

	public func font(traits: UIFontDescriptor.SymbolicTraits = [], weight: FontWeight? = nil) -> UIFont {
		var systemFont = UIFont.preferredFont(forTextStyle: textStyle)

		// Apply minimum weight
		if let weight = weight {
			let currentWeight = (systemFont.fontDescriptor.object(forKey: .face) as? String).flatMap(FontWeight.init)
			if weight.fontWeight > currentWeight?.fontWeight ?? 0 {
				systemFont = UIFont.systemFont(ofSize: systemFont.pointSize, weight: UIFont.Weight(rawValue: weight.fontWeight))
			}
		}

		return applySymbolicTraits(traits, toFont: systemFont, sanitize: false)
	}

	public func monoSpaceFont(traits: UIFontDescriptor.SymbolicTraits = []) -> UIFont {
		let systemFont = UIFont.preferredFont(forTextStyle: textStyle)
		let monoSpaceFont = UIFont(name: "Menlo", size: systemFont.pointSize * 0.9)!
		return applySymbolicTraits(traits, toFont: monoSpaceFont)
	}
}

func applySymbolicTraits(_ traits: UIFontDescriptor.SymbolicTraits, toFont font: UIFont, sanitize: Bool = true)
	-> UIFont
{
	var traits = traits

	if sanitize && !traits.isEmpty {
		var t = UIFontDescriptor.SymbolicTraits()

		if traits.contains(.traitBold) {
			t.insert(.traitBold)
		}

		if traits.contains(.traitItalic) {
			t.insert(.traitItalic)
		}

		traits = t
	}

	if traits.isEmpty {
		return font
	}

	let fontDescriptor = font.fontDescriptor.withSymbolicTraits(traits)
	return UIFont(descriptor: fontDescriptor!, size: font.pointSize)
}
