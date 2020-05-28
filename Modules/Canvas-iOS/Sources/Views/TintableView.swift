import UIKit

class TintableView: UIView {

    // MARK: - Properties

	var isHighlighted = false {
		didSet {
			updateTintColor()
		}
	}

	var normalTintColor: UIColor? {
		didSet {
			updateTintColor()
		}
	}

	var highlightedTintColor: UIColor? {
		didSet {
			updateTintColor()
		}
	}

	private var isSettingTintColor = false

    // MARK: - UIView

	override func tintColorDidChange() {
		super.tintColorDidChange()

		if isSettingTintColor {
			isSettingTintColor = false
			return
		}

		normalTintColor = tintColor
	}

    // MARK: - Tinting

	func updateTintColor() {
		isSettingTintColor = true
		tintColor = isHighlighted ? highlightedTintColor : normalTintColor
	}
}
