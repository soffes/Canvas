import UIKit

extension UIEdgeInsets {
	init(_ value: CGFloat) {
		top = value
		left = value
		right = value
		bottom = value
	}

	static let zero = UIEdgeInsets(0)
}
