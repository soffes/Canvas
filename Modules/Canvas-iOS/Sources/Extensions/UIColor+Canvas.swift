import UIKit

extension UIColor {
	var desaturated: UIColor {
		var hue: CGFloat = 0
		var brightness: CGFloat = 0
		var alpha: CGFloat = 0

		getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)

		return type(of: self).init(hue: hue, saturation: 0, brightness: brightness, alpha: alpha)
	}
}
