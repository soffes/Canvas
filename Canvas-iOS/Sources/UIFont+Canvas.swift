import UIKit

extension UIFont {
	var fontWithMonospaceNumbers: UIFont {
		let fontDescriptor = UIFontDescriptor(name: fontName, size: pointSize).fontDescriptorByAddingAttributes([
			UIFontDescriptorFeatureSettingsAttribute: [
				[
					UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
					UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
				]
			]
		])

		return UIFont(descriptor: fontDescriptor, size: pointSize)
	}
}
