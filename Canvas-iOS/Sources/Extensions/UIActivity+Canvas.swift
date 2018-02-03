import UIKit

extension UIActivity {
	func showBanner(text: String, style: BannerView.Style = .success) {
		guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController as? RootViewController,
			let splitViewController = rootViewController.viewController as? SplitViewController,
			var viewController = splitViewController.viewControllers.last
		else { return }

		if let top = (viewController as? UINavigationController)?.topViewController {
			viewController = top
		}

		rootViewController._showBanner(text: text, style: style, inViewController: viewController)

	}
}
