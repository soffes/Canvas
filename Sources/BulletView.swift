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

	// MARK: - Private

	let unorderedListItem: UnorderedListItem


	// MARK: - Initializers

	override init?(block: Annotatable, theme: Theme) {
		guard let unorderedListItem = block as? UnorderedListItem else { return nil }
		self.unorderedListItem = unorderedListItem

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

		theme.bulletColor.set()

		let rect = bulletRectForBounds(bounds)

		if unorderedListItem.indentation.isFilled {
			CGContextFillEllipseInRect(context, rect)
		} else {
			CGContextSetLineWidth(context, 2)
			CGContextStrokeEllipseInRect(context, CGRectInset(rect, 1, 1))
		}
	}


	// MARK: - Private

	private func bulletRectForBounds(bounds: CGRect) -> CGRect {
		let dimension: CGFloat = 8

		return CGRect(
			x: bounds.width - dimension - 6,
			y: floor((bounds.height - dimension) / 2),
			width: dimension,
			height: dimension
		)
	}
}
