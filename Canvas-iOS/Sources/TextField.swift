import UIKit
import CanvasCore
import CanvasText

final class TextField: UITextField {

	// MARK: - Properties

	override var placeholder: String? {
		didSet {
			guard let placeholder = placeholder, let font = font else { return }
			attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
				.font: font,
				.foregroundColor: Swatch.darkGray
			])
		}
	}

	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = Swatch.extraLightGray

		textColor = Swatch.black
		tintColor = Swatch.brand

		layer.cornerRadius = 4

		NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: .UIContentSizeCategoryDidChange, object: nil)
		updateFont()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override var intrinsicContentSize: CGSize {
		var size = super.intrinsicContentSize
		size.height = 48
		return size
	}


	// MARK: - UITextField

	override func textRect(forBounds bounds: CGRect) -> CGRect {
		var rect = bounds

		if rightView != nil {
			rect.size.width -= rect.intersection(rightViewRect(forBounds: bounds)).width
		}

		return rect.insetBy(dx: 12, dy: 12)
	}

	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return textRect(forBounds: bounds)
	}

	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return textRect(forBounds: bounds)
	}

	override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
		var rect = super.rightViewRect(forBounds: bounds)
		rect.origin.x -= 6
		return rect
	}


	// MARK: - Private

	@objc private func updateFont() {
		font = TextStyle.body.font()
	}
}
