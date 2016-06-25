//
//  LightTheme.swift
//  CanvasCore
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015–2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasText
import X

public struct LightTheme: Theme {

	// MARK: - Primary Colors

	public let backgroundColor = Swatch.white
	public let foregroundColor = Swatch.black
	public var tintColor: X.Color


	// MARK: - Block Colors
	
	public let titlePlaceholderColor = Swatch.lightGray
	public let bulletColor = Swatch.gray
	public let uncheckedCheckboxColor = Swatch.gray
	public let orderedListItemNumberColor = Swatch.gray
	public let codeColor = Swatch.gray
	public let codeBlockBackgroundColor = Swatch.extraLightGray
	public let codeBlockLineNumberColor = Swatch.lightGray
	public let codeBlockLineNumberBackgroundColor = Swatch.lightGray
	public let blockquoteColor = Swatch.gray
	public let blockquoteBorderColor = Swatch.lightGray
	public let headingOneColor = Swatch.black
	public let headingTwoColor = Swatch.black
	public let headingThreeColor = Swatch.black
	public let headingFourColor = Swatch.black
	public let headingFiveColor = Swatch.black
	public let headingSixColor = Swatch.black
	public let horizontalRuleColor = Swatch.gray
	public let imagePlaceholderColor = Swatch.gray
	public let imagePlaceholderBackgroundColor = Swatch.extraLightGray


	// MARK: - Span Colors

	public let foldedColor = Swatch.gray
	public let strikethroughColor = Swatch.gray
	public let linkURLColor = Swatch.gray
	public let codeSpanColor = Swatch.gray
	public let codeSpanBackgroundColor = Swatch.extraLightGray
	public let commentBackgroundColor = Swatch.comment


	// MARK: - Initializers

	public init(tintColor: X.Color) {
		self.tintColor = tintColor
	}
}
