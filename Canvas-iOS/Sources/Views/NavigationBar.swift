import UIKit
import CanvasCore

final class NavigationBar: UINavigationBar {

	// MARK: - Properties

	var titleColor: UIColor? {
		didSet {
			updateTitleColor()
		}
	}

	var borderColor: UIColor? {
		set {
			borderView.backgroundColor = newValue
		}

		get {
			return borderView.backgroundColor
		}
	}

	private let borderView: LineView = {
		let view = LineView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()


	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		barTintColor = Swatch.white
		isTranslucent = false
		shadowImage = UIImage()
		backIndicatorImage = UIImage(named: "ChevronLeft")
		backIndicatorTransitionMaskImage = UIImage(named: "ChevronLeft")

		borderColor = Swatch.border

		addSubview(borderView)

		NSLayoutConstraint.activate([
			borderView.topAnchor.constraint(equalTo: bottomAnchor),
			borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
			borderView.trailingAnchor.constraint(equalTo: trailingAnchor)
		])
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func tintColorDidChange() {
		super.tintColorDidChange()
		updateTitleColor()
	}


	// MARK: - Private

	private func updateTitleColor() {
		titleTextAttributes = [
			.font: Font.sansSerif(weight: .medium),
			.foregroundColor: tintAdjustmentMode == .dimmed ? tintColor : (titleColor ?? Swatch.darkGray)
		]
	}
}
