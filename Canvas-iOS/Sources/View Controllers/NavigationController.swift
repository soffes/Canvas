import CanvasCore
import UIKit

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
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		// Call didShow if the animation is canceled
		transitionCoordinator?.notifyWhenInteractionChanges { [weak self] context in
			guard context.isCancelled, let delegate = self, let from = context.viewController(forKey: .from) else {
				return
			}

			delegate.navigationController(navigationController, willShow: viewController, animated: animated)

			let animationCompletion = context.transitionDuration * TimeInterval(context.percentComplete)
			DispatchQueue.main.asyncAfter(deadline: .now() + animationCompletion) { [weak delegate] in
				delegate?.navigationController(navigationController, didShow: from, animated: animated)
			}
		}

		updateTintColor(with: viewController)
	}

	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		updateTintColor(with: viewController)
	}
}
