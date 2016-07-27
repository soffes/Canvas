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
	public var tintColor: Color


	// MARK: - Block Colors
	
	public let titlePlaceholderColor = Swatch.lightGray
	public let bulletColor = Swatch.darkGray
	public let uncheckedCheckboxColor = Swatch.darkGray
	public let orderedListItemNumberColor = Swatch.darkGray
	public let codeColor = Swatch.darkGray
	public let codeBlockBackgroundColor = Swatch.extraLightGray
	public let codeBlockLineNumberColor = Swatch.gray
	public let codeBlockLineNumberBackgroundColor = Swatch.lightGray
	public let blockquoteColor = Swatch.darkGray
	public let blockquoteBorderColor = Swatch.lightGray
	public let headingOneColor = Swatch.black
	public let headingTwoColor = Swatch.black
	public let headingThreeColor = Swatch.black
	public let headingFourColor = Swatch.black
	public let headingFiveColor = Swatch.black
	public let headingSixColor = Swatch.black
	public let horizontalRuleColor = Swatch.darkGray
	public let imagePlaceholderColor = Swatch.darkGray
	public let imagePlaceholderBackgroundColor = Swatch.extraLightGray


	// MARK: - Span Colors

	public let foldedColor = Swatch.darkGray
	public let strikethroughColor = Swatch.darkGray
	public let linkURLColor = Swatch.darkGray
	public let codeSpanColor = Swatch.darkGray
	public let codeSpanBackgroundColor = Swatch.extraLightGray
	public let commentBackgroundColor = Swatch.comment


	// MARK: - Initializers

	public init(tintColor: Color) {
		self.tintColor = tintColor
	}
}
