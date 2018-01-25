//
//  IndicatorButton.swift
//  Canvas
//
//  Created by Sam Soffes on 5/13/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

final class IndicatorButton: PillButton {

	// MARK: - Properties

	var loading = false {
		didSet {
			titleLabel?.alpha = loading ? 0 : 1
			isEnabled = !loading

			if loading {
				activityIndicator.startAnimating()
			} else {
				activityIndicator.stopAnimating()
			}
		}
	}

	let activityIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
		indicator.translatesAutoresizingMaskIntoConstraints = false
		indicator.isUserInteractionEnabled = false
		indicator.hidesWhenStopped = true
		indicator.color = Swatch.darkGray
		return indicator
	}()


	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		addSubview(activityIndicator)

		NSLayoutConstraint.activate([
			activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
