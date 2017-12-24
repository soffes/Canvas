//
//  BlockquoteBorderView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/20/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import CanvasNative
import X

final class BlockquoteBorderView: ViewType, Annotation {

	// MARK: - Private

	var block: Annotatable

	var theme: Theme {
		didSet {
			#if os(OSX)
				needsDisplay = true
			#else
				backgroundColor = theme.backgroundColor
				setNeedsDisplay()
			#endif
		}
	}

	let placement = AnnotationPlacement.ExpandedLeadingGutter

	var horizontalSizeClass: UserInterfaceSizeClass = .Unspecified


	// MARK: - Initializers

	init?(block: Annotatable, theme: Theme) {
		guard let blockquote = block as? Blockquote else { return nil }
		self.block = blockquote
		self.theme = theme

		super.init(frame: .zero)

		#if !os(OSX)
			userInteractionEnabled = false
			contentMode = .Redraw
			backgroundColor = theme.backgroundColor
		#endif
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func drawRect(rect: CGRect) {
		#if os(OSX)
			guard let context = NSGraphicsContext.currentContext()?.CGContext else { return }

			theme.backgroundColor.setFill()
			CGContextFillRect(context, bounds)
		#else
			guard let context = UIGraphicsGetCurrentContext() else { return }
		#endif

		theme.blockquoteBorderColor.setFill()

		let rect = borderRectForBounds(bounds)
		CGContextFillRect(context, rect)
	}


	// MARK: - Private

	private func borderRectForBounds(bounds: CGRect) -> CGRect {
		return CGRect(
			x: 1,
			y: 0,
			width: 4,
			height: bounds.height
		)
	}
}
