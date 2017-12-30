//
//  WebActivity.swift
//  Canvas
//
//  Created by Sam Soffes on 11/18/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class WebActivity: UIActivity {

	// MARK: - Properties

	var url: URL?
	var schemePrefix: String?


	// MARK: - UIActivity

	override func prepare(withActivityItems activityItems: [Any]) {
		for activityItem in activityItems {
			if let url = activityItem as? URL {
				self.url = url
				return
			}
		}
	}
}
