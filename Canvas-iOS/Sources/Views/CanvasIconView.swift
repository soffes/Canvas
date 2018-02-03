import CanvasCore
import UIKit

final class CanvasIconView: TintableView {

    // MARK: - Properties

	var canvas: Canvas? {
		didSet {
			guard let canvas = canvas else { return }

			iconView.image = canvas.kind.icon.withRenderingMode(.alwaysTemplate)
		}
	}

	private let iconView: UIImageView = {
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .center
		return view
	}()

    // MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		addSubview(iconView)

		NSLayoutConstraint.activate([
			iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
			iconView.trailingAnchor.constraint(equalTo: trailingAnchor),
			iconView.topAnchor.constraint(equalTo: topAnchor),
			iconView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - UIView

	override var intrinsicContentSize: CGSize {
		return CGSize(width: 32, height: 32)
	}
}
