import UIKit

class FooterButton: PrefaceButton {

    // MARK: - Properties

	let lineView: LineView = {
		let view = LineView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

    // MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		addSubview(lineView)

		NSLayoutConstraint.activate([
			lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
			lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
			lineView.topAnchor.constraint(equalTo: topAnchor),

			heightAnchor.constraint(equalToConstant: 48)
		])
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
