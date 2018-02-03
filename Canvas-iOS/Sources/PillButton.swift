import UIKit
import CanvasCore
import CanvasText

class PillButton: UIButton {

	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = .clear

		layer.cornerRadius = 24
		layer.borderWidth = 2

		setTitleColor(Swatch.brand, for: .normal)
		setTitleColor(Swatch.lightBlue, for: .highlighted)
		setTitleColor(Swatch.darkGray, for: .disabled)

		NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: .UIContentSizeCategoryDidChange, object: nil)
		updateFont()
		updateBorderColor()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override var intrinsicContentSize: CGSize {
		var size = super.intrinsicContentSize
		size.height = 48
		size.width += 32 * 2
		return size
	}


	// MARK: - UIControl

	override var isEnabled: Bool {
		didSet {
			updateBorderColor()
		}
	}

	override var isHighlighted: Bool {
		didSet {
			updateBorderColor()
		}
	}

	override var isSelected: Bool {
		didSet {
			updateBorderColor()
		}
	}


	// MARK: - Private

	private func updateBorderColor() {
		layer.borderColor = titleColor(for: state)?.cgColor
	}

	@objc func updateFont() {
		titleLabel?.font = TextStyle.body.font(weight: .medium)
	}
}
