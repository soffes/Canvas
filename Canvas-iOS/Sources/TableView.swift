import UIKit
import CanvasCore

final class TableView: UITableView {
	override func tintColorDidChange() {
		super.tintColorDidChange()

		if style != .Grouped {
			return
		}

		backgroundColor = tintAdjustmentMode == .Dimmed ? Swatch.groupedTableBackground.desaturated : Swatch.groupedTableBackground
	}
}
