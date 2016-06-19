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

	public let backgroundColor = Color.white
	public let foregroundColor = Color.black
	public var tintColor: X.Color


	// MARK: - Block Colors
	
	public let titlePlaceholderColor = Color.lightGray
	public let bulletColor = Color.gray
	public let uncheckedCheckboxColor = Color.gray
	public let orderedListItemNumberColor = Color.gray
	public let codeColor = Color.gray
	public let codeBlockBackgroundColor = Color.extraLightGray
	public let codeBlockLineNumberColor = Color.lightGray
	public let codeBlockLineNumberBackgroundColor = Color.lightGray
	public let blockquoteColor = Color.gray
	public let blockquoteBorderColor = Color.lightGray
	public let headingOneColor = Color.black
	public let headingTwoColor = Color.black
	public let headingThreeColor = Color.black
	public let headingFourColor = Color.black
	public let headingFiveColor = Color.black
	public let headingSixColor = Color.black
	public let horizontalRuleColor = Color.gray
	public let imagePlaceholderColor = Color.gray
	public let imagePlaceholderBackgroundColor = Color.extraLightGray


	// MARK: - Span Colors

	public let foldedColor = Color.gray
	public let strikethroughColor = Color.gray
	public let linkURLColor = Color.gray
	public let codeSpanColor = Color.gray
	public let codeSpanBackgroundColor = Color.extraLightGray
	public let commentBackgroundColor = Color.comment


	// MARK: - Initializers

	public init(tintColor: X.Color) {
		self.tintColor = tintColor
	}
}
