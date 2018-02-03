import UIKit
import CanvasCore
import CanvasText

final class GrayButton: UIButton {

	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = Swatch.lightGray

		layer.cornerRadius = 4

		setTitleColor(Swatch.darkGray, for: .normal)
		setTitleColor(Swatch.black, for: .highlighted)
		setTitleColor(Swatch.extraLightGray, for: .disabled)

		NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: .UIContentSizeCategoryDidChange, object: nil)
		updateFont()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override var intrinsicContentSize: CGSize {
		var size = super.intrinsicContentSize
		size.height = 32
		size.width += 32 * 2
		return size
	}


	// MARK: - UIControl

	override var isEnabled: Bool {
		didSet {
			backgroundColor = isEnabled ? Swatch.lightGray.withAlphaComponent(0.5) : Swatch.lightGray
		}
	}

	override var isHighlighted: Bool {
		didSet {
			backgroundColor = isHighlighted ? Swatch.lightGray.withAlphaComponent(0.8) : Swatch.lightGray
		}
	}

	override var isSelected: Bool {
		didSet {
			backgroundColor = isSelected ? Swatch.lightGray.withAlphaComponent(0.8) : Swatch.lightGray
		}
	}


	// MARK: - Private

	@objc func updateFont() {
		titleLabel?.font = TextStyle.body.font(weight: .medium)
	}
}
