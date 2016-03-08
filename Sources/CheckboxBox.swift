//
//  CheckboxView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/17/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasNative

final class CheckboxView: Annotation {

	// MARK: - Properties

	private let button: CheckboxButton

	override var theme: Theme {
		didSet {
			button.theme = theme
		}
	}


	// MARK: - Initializers

	override init?(block: Annotatable, theme: Theme) {
		guard let checklistItem = block as? ChecklistItem else { return nil }
		button = CheckboxButton(checklist: checklistItem, theme: theme)

		super.init(block: block, theme: theme)

		addSubview(button)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func layoutSubviews() {
		button.frame = bounds
	}
}


private final class CheckboxButton: UIButton {

	// MARK: - Properties

	let checklist: ChecklistItem

	var theme: Theme {
		didSet {
			backgroundColor = theme.backgroundColor
			setNeedsDisplay()
		}
	}


	// MARK: - Initializers

	init(checklist: ChecklistItem, theme: Theme) {
		self.checklist = checklist
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
		let rect = checkboxRectForBounds(bounds)

		if checklist.completion == .Complete {
			tintColor.setFill()
			UIBezierPath(roundedRect: rect, cornerRadius: 3).fill()

			if let checkmark = UIImage(named: "checkmark") {
				Color.whiteColor().setFill()
				checkmark.drawAtPoint(CGPoint(x: rect.origin.x + (rect.width - checkmark.size.width) / 2, y: (bounds.height - checkmark.size.height) / 2))
			}
			return
		}

		theme.placeholderColor.setStroke()
		let path = UIBezierPath(roundedRect: CGRectInset(rect, 1, 1), cornerRadius: 3)
		path.lineWidth = 2
		path.stroke()
	}

	override func tintColorDidChange() {
		super.tintColorDidChange()
		setNeedsDisplay()
	}


	// MARK: - Private

	private func checkboxRectForBounds(bounds: CGRect) -> CGRect {
		let size: CGFloat = 16
		return CGRect(x: bounds.size.width - size - 4, y: floor((bounds.size.height - size) / 2) + 0.5, width: size, height: size)
	}
}
