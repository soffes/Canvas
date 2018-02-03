import SafariServices
import UIKit

final class WebViewController: SFSafariViewController {

    // MARK: - Properties

	let originalURL: URL

    // MARK: - Initializers

	convenience init(url: URL) {
		self.init(url: url, configuration: Configuration())
	}

	override init(url: URL, configuration: SFSafariViewController.Configuration) {
		originalURL = url
		super.init(url: url, configuration: configuration)
	}

    // MARK: - UIViewController

	override var previewActionItems: [UIPreviewActionItem] {
		let copyAction = UIPreviewAction(title: "Copy URL", style: .default) { [weak self] _, _ in
			UIPasteboard.general.url = self?.originalURL
		}

		let safariAction = UIPreviewAction(title: "Open in Safari", style: .default) { [weak self] _, _ in
			guard let url = self?.originalURL else { return }
			UIApplication.shared.open(url)
		}

		return [copyAction, safariAction]
	}
}
