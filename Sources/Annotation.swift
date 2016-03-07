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

	public var block: BlockNode
	public var theme: Theme {
		didSet {
			setNeedsDisplay()
		}
	}


	// MARK: - Initializers

	public init(block: BlockNode, theme: Theme) {
		self.block = block
		self.theme = theme
		super.init(frame: .zero)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
