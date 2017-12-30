//
//  LineView.swift
//  Canvas
//
//  Created by Sam Soffes on 6/3/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

final class LineView: UIView {
	
	// MARK: - Initializers
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = Swatch.border
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - UIView
	
	override func sizeThatFits(_ size: CGSize) -> CGSize {
		return CGSize(width: size.width, height: intrinsicContentSize.height)
	}

	override var intrinsicContentSize: CGSize {
		return CGSize(width: UIViewNoIntrinsicMetric, height: 1 / max(1, traitCollection.displayScale))
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		invalidateIntrinsicContentSize()
	}
}
