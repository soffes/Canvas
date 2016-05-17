//
//  CodeBlockView.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasNative

final class CodeBlockView: View, Annotation {

	// MARK: - Private

	var block: Annotatable

	var theme: Theme {
		didSet {
			backgroundColor = theme.codeBackground
			tintColor = theme.tintColor
			setNeedsDisplay()
		}
	}

	var horizontalSizeClass: UserInterfaceSizeClass = .Unspecified

	let placement = AnnotationPlacement.ExpandedBackground

	
	// MARK: - Initializers

	init?(block: Annotatable, theme: Theme) {
		guard let codeBlock = block as? CodeBlock else { return nil }
		self.block = codeBlock
		self.theme = theme

		super.init(frame: .zero)

		userInteractionEnabled = false
		contentMode = .Redraw
		backgroundColor = theme.codeBackground
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
