import UIKit
import Static
import CanvasCore

final class ValueCell: UITableViewCell, Cell {
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .value1, reuseIdentifier: reuseIdentifier)
		textLabel?.textColor = Swatch.black
		detailTextLabel?.textColor = Swatch.darkGray
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(row: Row) {
		textLabel?.text = row.text
		detailTextLabel?.text = row.detailText
		imageView?.image = row.image

		switch row.accessory {
		case .disclosureIndicator:
			let view = UIImageView(image: UIImage(named: "ChevronRightSmall"))
			view.tintColor = Swatch.lightGray
			accessoryView = view
		default:
			accessoryType = row.accessory.type
			accessoryView = row.accessory.view
		}
	}
}
