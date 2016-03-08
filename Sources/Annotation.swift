//
//  Annotation.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasNative

public typealias View = UIView

public class Annotation: View {

	// MARK: - Properties

	public var block: Annotatable
	public var theme: Theme {
		didSet {
			backgroundColor = theme.backgroundColor
			setNeedsDisplay()
		}
	}


	// MARK: - Initializers

	public init?(block: Annotatable, theme: Theme) {
		self.block = block
		self.theme = theme

		super.init(frame: .zero)

		backgroundColor = theme.backgroundColor
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
