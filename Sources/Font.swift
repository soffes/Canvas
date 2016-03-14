//
//  Font.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit.NSFont
	public typealias FontType = NSFont
	// TODO: FontDescriptorSymbolicTraits
#else
	import UIKit.UIFont
	public typealias FontType = UIFont
	public typealias FontDescriptorSymbolicTraits = UIFontDescriptorSymbolicTraits
#endif

public typealias Font = FontType

extension Font {
	var fontWithMonospaceNumbers: Font {
		let fontDescriptor = UIFontDescriptor(name: fontName, size: pointSize).fontDescriptorByAddingAttributes([
			UIFontDescriptorFeatureSettingsAttribute: [
				[
					UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
					UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
				]
			]
			])

		return Font(descriptor: fontDescriptor, size: pointSize)
	}
}
