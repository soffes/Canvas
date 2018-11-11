import CanvasCore
import UIKit

final class SearchBarContainer: UIView {

    // MARK: - Properties

	let searchBar: UISearchBar

	private let topBorderView = UIView()
	private let bottomBorderView = UIView()

    // MARK: - Initializers

	init(searchBar: UISearchBar) {
		self.searchBar = searchBar

		super.init(frame: searchBar.bounds)

		autoresizingMask = [.flexibleWidth]

		searchBar.barTintColor = Swatch.white
		searchBar.layer.borderColor = Swatch.white.cgColor
		searchBar.layer.borderWidth = 1
		searchBar.backgroundColor = Swatch.white
		searchBar.isTranslucent = false
		searchBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		searchBar.setImage(UIImage(named: "SearchSmall"), for: .search, state: .normal)
		addSubview(searchBar)

		if let string = searchBar.placeholder {
			let placeholder = NSAttributedString(string: string, attributes: [
				.foregroundColor: Swatch.darkGray,
				.font: Font.sansSerif(size: .small)
			])
			UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = placeholder
		}

		topBorderView.backgroundColor = Swatch.border
		addSubview(topBorderView)

		bottomBorderView.backgroundColor = Swatch.border
		addSubview(bottomBorderView)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - UIView

	override func addSubview(_ view: UIView) {
		super.addSubview(view)

		// UISearchController removes this view and then adds it back. Move it to the back when it's added so it stays
		// below the borders.
		if view == searchBar {
			sendSubviewToBack(view)
		}
	}

	override func sizeThatFits(_ size: CGSize) -> CGSize {
		return CGSize(width: size.width, height: 44)
	}

	override func layoutSubviews() {
		let borderHeight = 1 / traitCollection.displayScale

		topBorderView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: borderHeight)
		bottomBorderView.frame = CGRect(x: 0, y: bounds.height - borderHeight, width: bounds.width, height: borderHeight)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		setNeedsLayout()
	}
}
