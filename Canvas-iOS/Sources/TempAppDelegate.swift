import UIKit

@UIApplicationMain final class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		let window = UIWindow()

		let viewController = UIViewController()
		viewController.view.backgroundColor = .red
		window.rootViewController = viewController

		self.window = window
		window.makeKeyAndVisible()

		return true
	}
}
