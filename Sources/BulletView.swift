//
//  BulletView.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/17/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasNative

final class BulletView: Annotation {

	// MARK: - Initializers

	override init(block: BlockNode, theme: Theme) {
		super.init(block: block, theme: theme)

		userInteractionEnabled = false
		backgroundColor = .clearColor()
		contentMode = .Redraw
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func drawRect(rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext(), block = block as? UnorderedListItem else { return }

		theme.bulletColor.set()

		if block.indentation.isFilled {
			CGContextFillEllipseInRect(context, bounds)
		} else {
			CGContextSetLineWidth(context, 2)
			CGContextStrokeEllipseInRect(context, CGRectInset(bounds, 1, 1))
		}
	}

	override func sizeThatFits(size: CGSize) -> CGSize {
		return intrinsicContentSize()
	}

	override func intrinsicContentSize() -> CGSize {
		return CGSize(width: 8, height: 8)
	}
}
