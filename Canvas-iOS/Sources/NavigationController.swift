import UIKit
import CanvasCore

final class NavigationController: UINavigationController {

	// MARK: - Properties

	private let defaultTintColor = Swatch.brand
	private let defaultTitleColor = Swatch.black


	// MARK: - Initializers

	override init(rootViewController: UIViewController) {
		super.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)

		viewControllers = [rootViewController]

		updateTintColor(with: view.tintColor)

		delegate = self
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)
	}

	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - Private

	private func updateTintColor(with viewController: UIViewController) {
		var target = viewController

		// Handle nested navigation controllers for when the split view is collapsed
		if let top = (viewController as? UINavigationController)?.topViewController {
			target = top
		}

		let tintColor = (target as? TintableEnvironment)?.preferredTintColor
		updateTintColor(with: tintColor)
	}

	private func updateTintColor(with tintColor: UIColor?) {
		let itemsColor = tintColor ?? defaultTintColor
		view.tintColor = itemsColor
		navigationBar.tintColor = itemsColor
	}
}


extension NavigationController: UINavigationControllerDelegate {
	func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
		// Call didShow if the animation is canceled
		transitionCoordinator?.notifyWhenInteractionEnds { [weak self] context in
			guard context.isCancelled(), let delegate = self, let from = context.viewControllerForKey(UITransitionContextFromViewControllerKey) else { return }
			delegate.navigationController(navigationController, willShowViewController: from, animated: animated)

			let animationCompletion = context.transitionDuration() * TimeInterval(context.percentComplete())
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(animationCompletion) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
				delegate.navigationController(navigationController, didShowViewController: from, animated: animated)
			}
		}

		updateTintColor(with: viewController)
	}

	func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
		updateTintColor(with: viewController)
	}
}
