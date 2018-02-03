import UIKit
import CanvasCore
import CanvasText

class SectionHeaderView: UIView {

	// MARK: - Properties

	let textLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = Swatch.black
		return label
	}()


	// MARK: - Initializers

	convenience init(title: String) {
		self.init(frame: CGRect(x: 0, y: 0, width: 320, height: 30))
		textLabel.text = title
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		autoresizingMask = [.FlexibleWidth]

		addSubview(textLabel)

		NSLayoutConstraint.activate([
			textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			textLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
			textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
			textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
		])

		NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: UIContentSizeCategoryDidChangeNotification, object: nil)
		updateFont()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func tintColorDidChange() {
		super.tintColorDidChange()
		backgroundColor = tintAdjustmentMode == .Dimmed ? Swatch.extraLightGray.desaturated : Swatch.extraLightGray
	}


	// MARK: - Fonts

	func updateFont() {
		textLabel.font = TextStyle.callout.font(weight: .medium)
	}
}
