import UIKit

final class ChromeActivity: WebActivity {

    // MARK: - UIActivity

	override var activityType: UIActivity.ActivityType? {
		return UIActivity.ActivityType(rawValue: "open-in-chrome")
	}

	override var activityTitle: String? {
		return "Open in Chrome" // TODO: Localize
	}

	override var activityImage: UIImage? {
		return UIImage(named: "Chrome")
	}

	override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
		for activityItem in activityItems {
			if let activityURL = activityItem as? URL, let chromeScheme = chromeScheme(for: activityURL),
				let chromeURL = URL(string: "\(chromeScheme)://"), UIApplication.shared.canOpenURL(chromeURL)
			{
				return true
			}
		}

		return false
	}

	override func perform() {
		guard let url = self.url else {
			activityDidFinish(false)
			return
		}

		guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true),
			let chromeScheme = chromeScheme(for: url)
		else {
			activityDidFinish(false)
			return
		}

		components.scheme = chromeScheme

		guard let chromeURL = components.url else {
			activityDidFinish(false)
			return
		}

		UIApplication.shared.open(chromeURL)
		activityDidFinish(true)
	}

    // MARK: - Private

	private func chromeScheme(for url: URL) -> String? {
		if url.scheme == "http" {
			return "googlechrome"
		}

		if url.scheme == "https" {
			return "googlechromes"
		}

		return nil
	}
}
