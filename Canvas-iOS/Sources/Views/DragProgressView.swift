import UIKit
import CanvasCore

final class DragProgressView: UIView {

    // MARK: - Properties

	private let imageView: UIImageView = {
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.tintColor = Swatch.gray
		view.contentMode = .center
		return view
	}()

    // MARK: - Initializers

	init(icon: UIImage?, isLeading: Bool) {
		super.init(frame: .zero)
		backgroundColor = Swatch.extraLightGray
		isUserInteractionEnabled = false

		imageView.image = icon
		addSubview(imageView)

		imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

		if isLeading {
			let x = imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
			x.priority = .defaultLow

			NSLayoutConstraint.activate([
				x,
				imageView.trailingAnchor.constraint(lessThanOrEqualTo: leadingAnchor, constant: DragContext.threshold)
			])
		} else {
			let x = imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
			x.priority = .defaultLow

			NSLayoutConstraint.activate([
				x,
				imageView.leadingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: -DragContext.threshold)
			])
		}
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - Translation

	func translate(x: CGFloat) {
		let progress = min(abs(x) / DragContext.threshold, 1)
		imageView.tintColor = Swatch.extraLightGray.interpolateTo(color: Swatch.darkGray, progress: progress)
	}
}
