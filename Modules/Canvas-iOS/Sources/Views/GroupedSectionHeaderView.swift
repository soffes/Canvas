import CanvasCore
import CanvasText
import UIKit

final class GroupedSectionHeaderView: SectionHeaderView {

    // MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = Swatch.groupedTableBackground
		tintColor = Swatch.darkGray
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - UIView

	override func tintColorDidChange() {
		super.tintColorDidChange()
		textLabel.textColor = tintColor
	}

    // MARK: - Private

	override func updateFont() {
		super.updateFont()
		textLabel.font = TextStyle.footnote.font()
	}
}
