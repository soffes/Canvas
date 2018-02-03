import CanvasCore
import UIKit

final class TableView: UITableView {
	override func tintColorDidChange() {
		super.tintColorDidChange()

		if style != .grouped {
			return
		}

		backgroundColor = tintAdjustmentMode == .dimmed ? Swatch.groupedTableBackground.desaturated : Swatch.groupedTableBackground
	}
}
