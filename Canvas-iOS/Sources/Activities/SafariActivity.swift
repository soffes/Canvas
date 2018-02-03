import UIKit

final class SafariActivity: WebActivity {

    // MARK: - UIActivity

	override var activityType: UIActivityType? {
		return UIActivityType(rawValue: "open-in-safari")
	}

	override var activityTitle: String? {
		return "Open in Safari"
	}

	override var activityImage: UIImage? {
		return UIImage(named: "Safari")
	}

	override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
		for activityItem in activityItems {
			if let url = activityItem as? URL, UIApplication.shared.canOpenURL(url) {
				return true
			}
		}

		return false
	}

	override func perform() {
		let completed: Bool

		if let url = url {
			completed = true
			UIApplication.shared.open(url)
		} else {
			completed = false
		}

		activityDidFinish(completed)
	}
}
