//
//  BlockquoteBorderView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/20/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasNative

final class BlockquoteBorderView: View, Annotation {

	// MARK: - Private

	private let blockquote: Blockquote

	var block: Annotatable {
		return blockquote
	}

	var theme: Theme {
		didSet {
			backgroundColor = theme.backgroundColor
			tintColor = theme.tintColor
			setNeedsDisplay()
		}
	}

	var horizontalSizeClass: UserInterfaceSizeClass = .Unspecified


	// MARK: - Initializers

	init?(block: Annotatable, theme: Theme) {
		guard let blockquote = block as? Blockquote else { return nil }
		self.blockquote = blockquote
		self.theme = theme

		super.init(frame: .zero)

		userInteractionEnabled = false
		contentMode = .Redraw
		backgroundColor = theme.backgroundColor
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

	override func tintColorDidChange() {
		super.tintColorDidChange()
		setNeedsDisplay()
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
