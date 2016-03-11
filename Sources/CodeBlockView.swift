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

	var block: Annotatable {
		return codeBlock
	}

	var theme: Theme {
		didSet {
			backgroundColor = theme.codeBackground
			tintColor = theme.tintColor
			setNeedsDisplay()
		}
	}

	var horizontalSizeClass: UserInterfaceSizeClass = .Unspecified

	let style: AnnotationStyle = .Background

	private let codeBlock: CodeBlock


	// MARK: - Initializers

	init?(block: Annotatable, theme: Theme) {
		guard let codeBlock = block as? CodeBlock else { return nil }
		self.codeBlock = codeBlock
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
