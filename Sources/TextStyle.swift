//
//  TextStyle.swift
//  CanvasText
//
//  Created by Sam Soffes on 6/30/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

public enum FontWeight {
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
}

public enum TextStyle {
	case Title1
	case Title2
	case Title3
	case Headline
	case Subheadline
	case Body
	case Footnote
	case Caption1
	case Caption2
	case Callout
	
	public var textStyle: String {
		switch self {
		case .Title1: return UIFontTextStyleTitle1
		case .Title2: return UIFontTextStyleTitle2
		case .Title3: return UIFontTextStyleTitle3
		case .Headline: return UIFontTextStyleHeadline
		case .Subheadline: return UIFontTextStyleSubheadline
		case .Body: return UIFontTextStyleBody
		case .Footnote: return UIFontTextStyleFootnote
		case .Caption1: return UIFontTextStyleCaption1
		case .Caption2: return UIFontTextStyleCaption2
		case .Callout: return UIFontTextStyleCallout
		}
	}
	
	public func font(traits traits: UIFontDescriptorSymbolicTraits = [], weight: FontWeight? = nil) -> UIFont {
		var systemFont = UIFont.preferredFontForTextStyle(textStyle)
		
		if let weight = weight {
			systemFont = UIFont.systemFontOfSize(systemFont.pointSize, weight: weight.fontWeight)
		}
		
		return applySymbolicTraits(traits, toFont: systemFont, sanitize: false)
	}
	
	public func monoSpaceFont(traits traits: UIFontDescriptorSymbolicTraits = []) -> UIFont {
		let systemFont = UIFont.preferredFontForTextStyle(textStyle)
		let monoSpaceFont = UIFont(name: "Menlo", size: systemFont.pointSize * 0.9)!
		return applySymbolicTraits(traits, toFont: monoSpaceFont)
	}
}


func applySymbolicTraits(traits: UIFontDescriptorSymbolicTraits, toFont font: UIFont, sanitize: Bool = true) -> UIFont {
	var traits = traits
	
	if sanitize && !traits.isEmpty {
		var t = UIFontDescriptorSymbolicTraits()
		
		if traits.contains(.TraitBold) {
			t.insert(.TraitBold)
		}
		
		if traits.contains(.TraitItalic) {
			t.insert(.TraitItalic)
		}
		
		traits = t
	}
	
	if traits.isEmpty {
		return font
	}
	
	let fontDescriptor = font.fontDescriptor().fontDescriptorWithSymbolicTraits(traits)
	return UIFont(descriptor: fontDescriptor, size: font.pointSize)
}
