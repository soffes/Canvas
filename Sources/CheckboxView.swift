//
//  CheckboxView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/17/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import CanvasNative
import X

final class CheckboxView: UIButton, Annotation {

	// MARK: - Properties

	var block: Annotatable {
		didSet {
			guard let old = oldValue as? ChecklistItem, new = block as? ChecklistItem else { return }

			if old.state != new.state {
				setNeedsDisplay()
			}
		}
	}

	var theme: Theme {
		didSet {
			backgroundColor = theme.backgroundColor
			tintColor = theme.tintColor
			setNeedsDisplay()
		}
	}

	var horizontalSizeClass: UserInterfaceSizeClass = .Unspecified
	
	private let size: CGFloat = 20
	

	// MARK: - Initializers

	init?(block: Annotatable, theme: Theme) {
		guard let checklistItem = block as? ChecklistItem else { return nil }
		self.block = checklistItem
		self.theme = theme

		super.init(frame: .zero)

		backgroundColor = theme.backgroundColor
		contentMode = .Redraw
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func drawRect(rect: CGRect) {
		guard let checklistItem = block as? ChecklistItem else { return }

		let rect = checkboxRectForBounds(bounds)

		if checklistItem.state == .checked {
			tintColor.setFill()
			UIBezierPath(roundedRect: rect, cornerRadius: size / 2).fill()

			let bundle = NSBundle(forClass: CheckboxView.self)
			if let checkmark = UIImage(named: "CheckmarkSmall", inBundle: bundle, compatibleWithTraitCollection: nil) {
				theme.backgroundColor.setFill()
				checkmark.drawAtPoint(CGPoint(x: rect.origin.x + (rect.width - checkmark.size.width) / 2, y: rect.origin.y + (rect.height - checkmark.size.height) / 2))
			}
			return
		}

		theme.uncheckedCheckboxColor.setStroke()
		let path = UIBezierPath(roundedRect: CGRectInset(rect, 1, 1), cornerRadius: size / 2)
		path.lineWidth = 2
		path.stroke()
	}

	override func tintColorDidChange() {
		super.tintColorDidChange()
		setNeedsDisplay()
	}


	// MARK: - Private

	private func checkboxRectForBounds(bounds: CGRect) -> CGRect {
		return CGRect(
			x: bounds.size.width - size - 4,
			y: floor((bounds.size.height - size) / 2) - 1,
			width: size,
			height: size
		)
	}
}
