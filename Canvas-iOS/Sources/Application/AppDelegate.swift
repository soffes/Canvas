import CanvasCore
import UIKit

@UIApplicationMain final class AppDelegate: UIResponder {

    // MARK: - Properties

	var window: UIWindow?

    // MARK: - Private

//	private func open(canvasURL: NSURL) -> Bool {
//		// For now require an account
//		guard let splitViewController = (window?.rootViewController as? RootViewController)?.viewController as? SplitViewController else { return false }
//
//		let viewController = NavigationController(rootViewController: LoadCanvasViewController(account: account, canvasID: canvasID))
//
//		let show = {
//			splitViewController.presentViewController(viewController, animated: true, completion: nil)
//		}
//
//		if splitViewController.presentedViewController != nil {
//			splitViewController.presentedViewController?.dismissViewControllerAnimated(false, completion: show)
//		} else {
//			show()
//		}
//
//		return true
//	}
}

extension AppDelegate: UIApplicationDelegate {
	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
	{
		// Appearance
		UIImageView.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = Swatch.darkGray

		// Defaults
		DispatchQueue.main.async {
			UserDefaults.standard.register(defaults: [
				SleepPrevention.defaultsKey: SleepPrevention.whilePluggedIn.rawValue
			])

			if let info = Bundle.main.infoDictionary, let version = info["CFBundleVersion"] as? String,
				let shortVersion = info["CFBundleShortVersionString"] as? String
			{
				UserDefaults.standard.set("\(shortVersion) (\(version))", forKey: "HumanReadableVersion")
				UserDefaults.standard.synchronize()
			}
		}

		// Shortcut items
		application.shortcutItems = [
			UIApplicationShortcutItem(type: "shortcut-new", localizedTitle: LocalizedString.newCanvasCommand.string,
									  localizedSubtitle: nil,
									  icon: UIApplicationShortcutIcon(templateImageName: "New Canvas Shortcut"),
									  userInfo: nil)
		]

		let browser = UIDocumentBrowserViewController(forOpeningFilesWithContentTypes: [Document.uti])
		browser.delegate = self

		let window = UIWindow()
		window.rootViewController = SplitViewController(
			masterViewController: browser,
			detailViewController: NavigationController(rootViewController: PlaceholderViewController())
		)
		window.makeKeyAndVisible()
		self.window = window

		return true
	}

//	func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
//		showPersonalNotes() { viewController in
//			guard let viewController = viewController else {
//				completionHandler(false)
//				return
//			}
//
//			if shortcutItem.type == "shortcut-new" {
//				viewController.ready = {
//					viewController.createCanvas()
//				}
//			} else if shortcutItem.type == "shortcut-search" {
//				viewController.ready = {
//					viewController.search()
//				}
//			}
//
//			completionHandler(true)
//		}
//	}
//
//	func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([Any]?) -> Void) -> Bool {
//		guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else { return false }
//
//		// Open canvas
//		if open(canvasURL: url) {
//			return true
//		}
//
//		// Verify account
//		if let components = url.pathComponents, components.count == 2 && components[1] == "verify" {
//			return verifyAccount(url: url)
//		}
//
//		// Fallback
//		application.openURL(url)
//		return false
//	}
}

extension AppDelegate: UIDocumentBrowserViewControllerDelegate {
	func showDocument(at url: URL) {
		let document = Document(fileURL: url)
		document.open { [weak self] success in
			if success {
				let viewController = NavigationController(rootViewController: EditorViewController(document: document))
				(self?.window?.rootViewController as? SplitViewController)?.show(viewController, sender: self)
			} else {
				// TODO: Handle
				fatalError("Failed to open document")
			}
		}
	}

	func show(_ document: Document) {
		let viewController = EditorViewController(document: document)
		(window?.rootViewController as? SplitViewController)?.show(viewController, sender: self)
	}

	func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
		showDocument(at: documentURLs[0])
	}

	func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
		do {
			try Document.create { result in
				switch result {
				case let .success(document):
					importHandler(document.fileURL, .move)
				case .failure:
					// Show error
					importHandler(nil, .none)
				}
			}
		} catch {
			// Show error
			importHandler(nil, .none)
		}
	}

	func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
		showDocument(at: sourceURL)
	}
}

enum Result<T> {
	case success(T)
	case failure(Error)
}

private let coordinationQueue = DispatchQueue(label: "com.nothingmagical.canvas.document-queue")

extension Document {
	static func create(completion: @escaping (Result<Document>) -> Void) throws {
		let targetURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Untitled").appendingPathExtension("canvas")

		coordinationQueue.async {
			let document = Document(fileURL: targetURL)
			var error: NSError?
			NSFileCoordinator(filePresenter: nil).coordinate(writingItemAt: targetURL, error: &error) { url in
				document.save(to: url, for: .forCreating) { success in
					DispatchQueue.main.async {
						if success {
							completion(.success(document))
						} else {
							completion(.failure(Error.unableToSave))
						}
					}
				}
			}
			if let error = error {
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
	}
}
