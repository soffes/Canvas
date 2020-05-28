import CanvasCore
import Static
import UIKit

final class DestructiveButtonCell: UITableViewCell, Cell {
	override func tintColorDidChange() {
		textLabel?.textColor = tintAdjustmentMode == .dimmed ? tintColor: Swatch.destructive
		imageView?.tintColor = textLabel?.textColor
	}
}
