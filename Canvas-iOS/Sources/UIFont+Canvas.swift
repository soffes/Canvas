import UIKit

extension UIFont {
	var fontWithMonospaceNumbers: UIFont {
		let fontDescriptor = UIFontDescriptor(name: fontName, size: pointSize).addingAttributes([
			.featureSettings: [
				UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
				UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector
			]
		])

		return UIFont(descriptor: fontDescriptor, size: pointSize)
	}
}
