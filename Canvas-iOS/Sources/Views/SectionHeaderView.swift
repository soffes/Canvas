import CanvasCore
import CanvasText
import UIKit

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

		autoresizingMask = [.flexibleWidth]

		addSubview(textLabel)

		NSLayoutConstraint.activate([
			textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			textLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
			textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
			textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
		])

		NotificationCenter.default.addObserver(self, selector: #selector(updateFont),
											   name: UIContentSizeCategory.didChangeNotification, object: nil)
		updateFont()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - UIView

	override func tintColorDidChange() {
		super.tintColorDidChange()
		backgroundColor = tintAdjustmentMode == .dimmed ? Swatch.extraLightGray.desaturated : Swatch.extraLightGray
	}

    // MARK: - Fonts

	@objc func updateFont() {
		textLabel.font = TextStyle.callout.font(weight: .medium)
	}
}
