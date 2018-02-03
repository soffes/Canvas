import UIKit
import Static
import CanvasCore
import CanvasText

final class CanvasCell: UITableViewCell {

    // MARK: - Properties

	let iconView: CanvasIconView = {
		let view = CanvasIconView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.tintColor = UIColor(red: 0.478, green: 0.475, blue: 0.482, alpha: 1)
		view.highlightedTintColor = Swatch.white
		return view
	}()

	let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Swatch.white
		label.textColor = Swatch.black
		label.highlightedTextColor = Swatch.white
		label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		return label
	}()

	let summaryLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Swatch.white
		label.textColor = Swatch.black
		label.highlightedTextColor = Swatch.white
		return label
	}()

	let timeLabel: TickingLabel = {
		let label = TickingLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = Swatch.white
		label.textColor = Swatch.darkGray
		label.highlightedTextColor = Swatch.white
		label.textAlignment = .right
		return label
	}()

	let disclosureIndicatorView = UIImageView(image: UIImage(named: "ChevronRightSmall"))

	private var canvas: Canvas? {
		didSet {
			updateHighlighted()

			guard let canvas = canvas else {
				timeLabel.text = nil
				return
			}

			iconView.canvas = canvas

			if canvas.archivedAt == nil {
				titleLabel.textColor = Swatch.black
				summaryLabel.textColor = canvas.isEmpty ? Swatch.darkGray : Swatch.black
			} else {
				titleLabel.textColor = Swatch.darkGray
				summaryLabel.textColor = Swatch.darkGray
			}

			timeLabel.date = canvas.updatedAt
		}
	}

	private var noContent = false

    // MARK: - Initializers

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

		let view = UIView()
		view.backgroundColor = tintColor
		selectedBackgroundView = view

		accessoryView = disclosureIndicatorView

		contentView.addSubview(iconView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(summaryLabel)
		contentView.addSubview(timeLabel)

		let verticalSpacing: CGFloat = 2

		NSLayoutConstraint.activate([
			iconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			iconView.widthAnchor.constraint(equalToConstant: 28),
			iconView.heightAnchor.constraint(equalToConstant: 28),
			iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

			titleLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -verticalSpacing),
			titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
			titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor),

			summaryLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: verticalSpacing),
			summaryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			summaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

			timeLabel.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),
			timeLabel.trailingAnchor.constraint(equalTo: summaryLabel.trailingAnchor),
			timeLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100)
		])

		NotificationCenter.default.addObserver(self, selector: #selector(updateFonts), name: .UIContentSizeCategoryDidChange, object: nil)
		updateFonts()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - UIView

	override func tintColorDidChange() {
		super.tintColorDidChange()
		selectedBackgroundView?.backgroundColor = tintColor
	}

    // MARK: - UITableViewCell

	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		updateHighlighted()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		updateHighlighted()
	}

    // MARK: - Private

	private func updateHighlighted() {
		iconView.isHighlighted = isHighlighted || isSelected

		if iconView.isHighlighted {
			disclosureIndicatorView.tintColor = Swatch.white
		} else {
			disclosureIndicatorView.tintColor = canvas?.archivedAt == nil ? Swatch.cellDisclosureIndicator : Swatch.lightGray
		}
	}

	@objc private func updateFonts() {
		titleLabel.font = TextStyle.body.font(weight: .medium)
		timeLabel.font = TextStyle.footnote.font().fontWithMonospaceNumbers
		summaryLabel.font = TextStyle.subheadline.font()
	}
}


extension CanvasCell: Cell {
	func configure(row: Row) {
		titleLabel.text = row.text

		if let summary = row.detailText, !summary.isEmpty {
			summaryLabel.text = summary
		} else {
			summaryLabel.text = "No Content" // TODO: Localize
		}

		canvas = row.context?["canvas"] as? Canvas
	}
}
