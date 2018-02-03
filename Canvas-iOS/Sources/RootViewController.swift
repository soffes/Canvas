import UIKit
import CanvasCore

final class RootViewController: UIViewController {

	// MARK: - Properties

	var viewController: UIViewController? {
		willSet {
			guard let viewController = viewController else { return }

			// Collapse the primary view controller if it's displaying
			if let splitViewController = viewController as? UISplitViewController {
				splitViewController.preferredDisplayMode = .primaryHidden
			}

			viewController.presentedViewController?.dismiss(animated: false)

			viewController.viewWillDisappear(false)
			viewController.view.removeFromSuperview()
			viewController.viewDidDisappear(false)
			viewController.removeFromParentViewController()
		}

		didSet {
			guard let viewController = viewController else { return }
			addChildViewController(viewController)

			viewController.view.translatesAutoresizingMaskIntoConstraints = false
			viewController.viewWillAppear(false)
			view.addSubview(viewController.view)

			NSLayoutConstraint.activate([
				viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
				viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			])
			viewController.viewDidAppear(false)

			UIView.performWithoutAnimation {
				viewController.view.layoutIfNeeded()
			}

			setNeedsStatusBarAppearanceUpdate()
		}
	}


	// MARK: - UIViewController

	override var childViewControllerForStatusBarStyle: UIViewController? {
		return viewController
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return traitCollection.userInterfaceIdiom == .pad ? .all : .portrait
	}


	// MARK: - Internal

	func _showBanner(text: String, style: BannerView.Style = .success, inViewController viewController: UIViewController) {
		var top = viewController

		while let parent = top.parent {
			top = parent
		}

		let container = top.view!

		let banner = BannerView(style: style)
		banner.translatesAutoresizingMaskIntoConstraints = false
		banner.textLabel.text = text

		let mask = UIView()
		mask.translatesAutoresizingMaskIntoConstraints = false
		mask.clipsToBounds = true
		container.addSubview(mask)
		mask.addSubview(banner)

		// Split view makes this super annoying
		let navigationController = viewController.navigationController?.navigationController ?? viewController.navigationController
		let topAnchor = navigationController?.navigationBar.bottomAnchor ?? view.topAnchor
		let leadingAnchor = navigationController?.view.leadingAnchor ?? view.leadingAnchor
		let widthAnchor = navigationController?.view.widthAnchor ?? view.widthAnchor

		let outYConstraint = banner.bottomAnchor.constraint(equalTo: topAnchor)
		outYConstraint.priority = .defaultHigh

		let inYConstraint = banner.topAnchor.constraint(equalTo: topAnchor)
		inYConstraint.priority = .defaultLow

		NSLayoutConstraint.activate([
			outYConstraint,
			inYConstraint,
			banner.leadingAnchor.constraint(equalTo: leadingAnchor),
			banner.widthAnchor.constraint(equalTo: widthAnchor),

			mask.topAnchor.constraint(equalTo: topAnchor),
			mask.leadingAnchor.constraint(equalTo: banner.leadingAnchor),
			mask.widthAnchor.constraint(equalTo: banner.widthAnchor),
			mask.heightAnchor.constraint(equalTo: banner.heightAnchor)
		])
		banner.layoutIfNeeded()

		UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
			outYConstraint.isActive = false
			banner.layoutIfNeeded()
		}, completion: nil)

		UIView.animate(withDuration: 0.3, delay: 2.3, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
			outYConstraint.isActive = true
			banner.layoutIfNeeded()
		}, completion: { _ in
			mask.removeFromSuperview()
		})
	}
}
