//
//  WebViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 1/28/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import SafariServices

final class WebViewController: SFSafariViewController {

	// MARK: - Properties

	let originalURL: URL


	// MARK: - Initializers

	convenience init(url: URL) {
		self.init(url: url, entersReaderIfAvailable: false)
	}

	override init(url : URL, entersReaderIfAvailable: Bool) {
		originalURL = url
		super.init(url: url, entersReaderIfAvailable: entersReaderIfAvailable)
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
