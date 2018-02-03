import UIKit
import CanvasCore
import CanvasText

final class BannerView: UIView {

    // MARK: - Types

	enum Style {
		case success
		case info
		case failure

		var foregroundColor: UIColor {
			return Swatch.white
		}

		var backgroundColor: UIColor {
			switch self {
			case .success: return Swatch.green
			case .info: return Swatch.darkGray
			case .failure: return Swatch.destructive
			}
		}
	}

    // MARK: - Properties

	let textLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.textAlignment = .center
		return label
	}()

    // MARK: - Initializers

	init(style: Style) {
		super.init(frame: .zero)

		backgroundColor = style.backgroundColor

		textLabel.textColor = style.foregroundColor
		addSubview(textLabel)

		NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: .UIContentSizeCategoryDidChange, object: nil)
		updateFont()

		NSLayoutConstraint.activate([
			textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			textLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
			textLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
			textLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 12),
			textLabel.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: -12),
		])
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - Private

	@objc private func updateFont() {
		textLabel.font = TextStyle.callout.font(weight: .medium)
	}
}
