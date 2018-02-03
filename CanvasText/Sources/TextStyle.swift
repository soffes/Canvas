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

	public var textStyle: String {
		switch self {
		case .title1: return UIFontTextStyle.title1.rawValue
		case .title2: return UIFontTextStyle.title2.rawValue
		case .title3: return UIFontTextStyle.title3.rawValue
		case .headline: return UIFontTextStyle.headline.rawValue
		case .subheadline: return UIFontTextStyle.subheadline.rawValue
		case .body: return UIFontTextStyle.body.rawValue
		case .footnote: return UIFontTextStyle.footnote.rawValue
		case .caption1: return UIFontTextStyle.caption1.rawValue
		case .caption2: return UIFontTextStyle.caption2.rawValue
		case .callout: return UIFontTextStyle.callout.rawValue
		}
	}

	public func font(traits: UIFontDescriptorSymbolicTraits = [], weight: FontWeight? = nil) -> UIFont {
		var systemFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle(rawValue: textStyle))

		// Apply minimum weight
		if let weight = weight {
			let currentWeight = (systemFont.fontDescriptor.object(forKey: .face) as? String).flatMap(FontWeight.init)
			if weight.fontWeight > currentWeight?.fontWeight ?? 0 {
				systemFont = UIFont.systemFont(ofSize: systemFont.pointSize, weight: UIFont.Weight(rawValue: weight.fontWeight))
			}
		}

		return applySymbolicTraits(traits, toFont: systemFont, sanitize: false)
	}

	public func monoSpaceFont(traits: UIFontDescriptorSymbolicTraits = []) -> UIFont {
		let systemFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle(rawValue: textStyle))
		let monoSpaceFont = UIFont(name: "Menlo", size: systemFont.pointSize * 0.9)!
		return applySymbolicTraits(traits, toFont: monoSpaceFont)
	}
}


func applySymbolicTraits(_ traits: UIFontDescriptorSymbolicTraits, toFont font: UIFont, sanitize: Bool = true) -> UIFont {
	var traits = traits

	if sanitize && !traits.isEmpty {
		var t = UIFontDescriptorSymbolicTraits()

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
