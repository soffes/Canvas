import UIKit
import CanvasCore

// TODO: Get colors from theme
final class DragBackgroundView: UIView {
	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = .white
		isUserInteractionEnabled = false

		let topBorder = LineView()
		topBorder.translatesAutoresizingMaskIntoConstraints = false
		addSubview(topBorder)

		let bottomBorder = LineView()
		bottomBorder.translatesAutoresizingMaskIntoConstraints = false
		addSubview(bottomBorder)

		NSLayoutConstraint.activate([
			topBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
			topBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
			topBorder.bottomAnchor.constraint(equalTo: topAnchor),

			bottomBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
			bottomBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
			bottomBorder.topAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
