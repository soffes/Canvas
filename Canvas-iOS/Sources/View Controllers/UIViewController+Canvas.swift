import UIKit

extension UIViewController {
	func present(actionSheet: UIViewController, sender: Any?, animated: Bool = true, completion: (() -> Void)? = nil) {
		if let popover = actionSheet.popoverPresentationController {
			if let button = sender as? UIBarButtonItem {
				popover.barButtonItem = button
			} else if let sourceView = sender as? UIView {
				popover.sourceView = sourceView
			} else {
				popover.sourceView = view
			}
		}

		present(actionSheet, animated: animated, completion: completion)
	}

	@objc func dismissDetailViewController(_ sender: Any?) {
		if let splitViewController = splitViewController, !splitViewController.isCollapsed {
			splitViewController.dismissDetailViewController(sender)
			return
		}

		if let presenter = targetViewController(forAction: #selector(dismissDetailViewController), sender: sender) {
			presenter.dismissDetailViewController(self)
		}
	}

	func showBanner(text: String, style: BannerView.Style = .success) {
		guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController as? RootViewController else { return }
		rootViewController._showBanner(text: text, style: style, inViewController: self)

	}
}

extension UINavigationController {
	override func dismissDetailViewController(_ sender: Any?) {
		// Hack to fix nested navigation controllers that split view makes. Ugh.
		if viewControllers.count == 1 {
			navigationController?.popViewController(animated: true)
			return
		}
		popViewController(animated: true)
	}
}

extension UISplitViewController {
	override func dismissDetailViewController(_ sender: Any?) {
		showDetailViewController(NavigationController(rootViewController: PlaceholderViewController()), sender: sender)
	}
}
