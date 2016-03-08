//
//  BlockquoteBorderView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/20/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasNative

final class BlockquoteBorderView: Annotation {

	// MARK: - Private

	let blockquote: Blockquote


	// MARK: - Initializers

	override init?(block: Annotatable, theme: Theme) {
		guard let blockquote = block as? Blockquote else { return nil }
		self.blockquote = blockquote

		super.init(block: block, theme: theme)

		userInteractionEnabled = false
		contentMode = .Redraw
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func drawRect(rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else { return }

		theme.blockquoteBorderColor.setFill()

		let rect = borderRectForBounds(bounds)
		CGContextFillRect(context, rect)
	}


	// MARK: - Private

	private func borderRectForBounds(bounds: CGRect) -> CGRect {
		let dimension: CGFloat = 4

		return CGRect(
			x: bounds.width - dimension - 8,
			y: 0,
			width: dimension,
			height: bounds.height
		)
	}
}
