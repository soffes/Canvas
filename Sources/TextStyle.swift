//
//  TextStyle.swift
//  CanvasText
//
//  Created by Sam Soffes on 6/30/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

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
		case .title1: return UIFontTextStyleTitle1
		case .title2: return UIFontTextStyleTitle2
		case .title3: return UIFontTextStyleTitle3
		case .headline: return UIFontTextStyleHeadline
		case .subheadline: return UIFontTextStyleSubheadline
		case .body: return UIFontTextStyleBody
		case .footnote: return UIFontTextStyleFootnote
		case .caption1: return UIFontTextStyleCaption1
		case .caption2: return UIFontTextStyleCaption2
		case .callout: return UIFontTextStyleCallout
		}
	}
	
	public func font(traits traits: UIFontDescriptorSymbolicTraits = [], weight: FontWeight? = nil) -> UIFont {
		var systemFont = UIFont.preferredFontForTextStyle(textStyle)

		// Apply minimum weight
		if let weight = weight {
			let currentWeight = (systemFont.fontDescriptor().objectForKey(UIFontDescriptorFaceAttribute) as? String).flatMap(FontWeight.init)
			if weight.fontWeight > currentWeight?.fontWeight ?? 0 {
				systemFont = UIFont.systemFontOfSize(systemFont.pointSize, weight: weight.fontWeight)
			}
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
