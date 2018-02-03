import CanvasCore
import CanvasText
import UIKit

final class BillboardView: UIStackView {

    // MARK: - Properties

	let illustrationView = UIImageView()

	let titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = Swatch.black
		return label
	}()

	let subtitleLabel: UILabel = {
		let label = UILabel()
		label.textColor = Swatch.darkGray
		label.numberOfLines = 0
		label.textAlignment = .center
		return label
	}()

    // MARK: - Initializers

	convenience init() {
		self.init(frame: .zero)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		axis = .vertical
		alignment = .center
		layoutMargins = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
		isLayoutMarginsRelativeArrangement = true

		addArrangedSubview(illustrationView)
		addSpace(32)
		addArrangedSubview(titleLabel)
		addSpace(8)
		addArrangedSubview(subtitleLabel)

		NotificationCenter.default.addObserver(self, selector: #selector(updateFonts), name: .UIContentSizeCategoryDidChange, object: nil)
		updateFonts()
	}

	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - Private

	@objc private func updateFonts() {
		titleLabel.font = TextStyle.title1.font()
		subtitleLabel.font = TextStyle.body.font()
	}
}
