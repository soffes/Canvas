import UIKit
import CanvasCore

class PrefaceButton: PillButton {

	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		titleLabel?.numberOfLines = 0
		titleLabel?.textAlignment = .center
		layer.borderWidth = 0
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - Preface

	func set(preface: String, title: String) {
		// Use non-breaking spaces for the title
		let title = title.replacingOccurrences(of: " ", with: "\u{00A0}")

		// TODO: Localize
		let string = "\(preface) \(title)"
		let emphasizedRange = NSRange(
			location: (preface as NSString).length + 1,
			length: (title as NSString).length
		)

		let normalText = NSMutableAttributedString(string: string, attributes: [
			.font: Font.sansSerif(size: .body),
			.foregroundColor: Swatch.darkGray
		])

		normalText.setAttributes([
			.font: Font.sansSerif(size: .body, weight: .medium),
			.foregroundColor: Swatch.brand
		], range: emphasizedRange)

		setAttributedTitle(normalText, for: .normal)

		let highlightedText = NSMutableAttributedString(string: string, attributes: [
			.font: Font.sansSerif(size: .body),

			// TODO: Use a named color for this
			.foregroundColor: Swatch.darkGray.withAlphaComponent(0.6)
		])

		highlightedText.setAttributes([
			.font: Font.sansSerif(size: .body, weight: .medium),
			.foregroundColor: Swatch.lightBlue
		], range: emphasizedRange)

		setAttributedTitle(highlightedText, forState: .highlighted)

		let disabledText = NSAttributedString(string: string, attributes: [
			.font: Font.sansSerif(size: .body),
			.foregroundColor: Swatch.darkGray
		])
		setAttributedTitle(disabledText, forState: .disabled)
	}
}
