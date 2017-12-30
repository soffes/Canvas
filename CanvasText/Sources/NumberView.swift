//
//  NumberView.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/14/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasNative
import X

final class NumberView: ViewType, Annotation {

	// MARK: - Private

	var block: Annotatable

	var theme: Theme {
		didSet {
			backgroundColor = theme.backgroundColor
			tintColor = theme.tintColor
			setNeedsDisplay()
		}
	}

	var horizontalSizeClass: UserInterfaceSizeClass = .unspecified


	// MARK: - Initializers

	init?(block: Annotatable, theme: Theme) {
		guard let orderedListItem = block as? OrderedListItem else { return nil }
		self.block = orderedListItem
		self.theme = theme

		super.init(frame: .zero)

		isUserInteractionEnabled = false
		contentMode = .redraw
		backgroundColor = theme.backgroundColor
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func draw(_ rect: CGRect) {
		guard let block = block as? OrderedListItem else { return }

		let string = "\(block.number)." as NSString
		let attributes: Attributes = [
			.foregroundColor: theme.orderedListItemNumberColor,
			.font: TextStyle.body.font().fontWithMonospacedNumbers
		]

		let size = string.size(withAttributes: attributes)

		// TODO: It would be better if we could calculate this from the font
		let rect = CGRect(
			x: bounds.width - size.width - 4,
			y: ((bounds.height - size.height) / 2) - 1,
			width: size.width,
			height: size.height
		).integral

		string.draw(in: rect, withAttributes: attributes)
	}
}
