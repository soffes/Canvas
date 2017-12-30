//
//  Theme.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import CanvasNative
import X

public typealias Attributes = [NSAttributedStringKey : Any]

public protocol Theme {

	// MARK: - Primary Colors

	/// Editor background color
	var backgroundColor: Color { get }

	/// Primary text color
	var foregroundColor: Color { get }

	/// Tint color
	var tintColor: Color { get set }


	// MARK: - Block Colors

	/// Title placeholder color
	var titlePlaceholderColor: Color { get }

	/// Unordered list item bullet fill color
	var bulletColor: Color { get }

	/// Unchecked checkbox border color
	var uncheckedCheckboxColor: Color { get }

	/// Unordered list item number color
	var orderedListItemNumberColor: Color { get }

	/// Code block and code span text color
	var codeColor: Color { get }

	/// Code block background color
	var codeBlockBackgroundColor: Color { get }

	/// Code block line number text color
	var codeBlockLineNumberColor: Color { get }

	/// Code block line number background color
	var codeBlockLineNumberBackgroundColor: Color { get }

	/// Blockquote text color
	var blockquoteColor: Color { get }

	/// Blockquote border color
	var blockquoteBorderColor: Color { get }

	/// Heading level one color
	var headingOneColor: Color { get }

	/// Heading level two color
	var headingTwoColor: Color { get }

	/// Heading level three color
	var headingThreeColor: Color { get }

	/// Heading level four color
	var headingFourColor: Color { get }

	/// Heading level five color
	var headingFiveColor: Color { get }

	/// Heading level six color
	var headingSixColor: Color { get }

	/// Horizontal rule fill color
	var horizontalRuleColor: Color { get }

	/// Image placeholder icon color
	var imagePlaceholderColor: Color { get }

	/// Image placeholder background color
	var imagePlaceholderBackgroundColor: Color { get }


	// MARK: - Span Colors

	/// Color of folded markdown characters
	var foldedColor: Color { get }

	/// Strikethrough color
	var strikethroughColor: Color { get }

	/// Link URL color
	var linkURLColor: Color { get }

	/// Code span text color
	var codeSpanColor: Color { get }

	/// Code span background color
	var codeSpanBackgroundColor: Color { get }

	/// Comment background color
	var commentBackgroundColor: Color { get }


	// MARK: - Attributes

	/// Base attributes
	var baseAttributes: Attributes { get }

	/// Attributes for title
	var titleAttributes: Attributes { get }

	/// Attributes for a block
	///
	/// NSFontAttributeName must be present.
	///
	/// - parameter block: Block node to style
	/// - returns: Attributes for given block
	func attributes(for: BlockNode) -> Attributes

	/// Attributes for a span
	///
	/// NSFontAttributeName must be present.
	///
	/// - parameter block: Span node to style
	/// - parameter parentAttributes: Attributes of the parent node
	/// - returns: Attributes for given block
	func attributes(for: SpanNode, parentAttributes: Attributes) -> Attributes?

	/// Attributes for a folded range.
	///
	/// NSFontAttributeName must be present.
	///
	/// - parameter parentAttributes: Attributes of the parent node
	/// - returns: Attributes for given block
	func foldingAttributes(withParentAttributes parentAttributes: Attributes) -> Attributes

	/// Calculate spacing for a given block.
	///
	/// - parameter block: Block to layout
	/// - parameter horizontalSizeClass: Horizontal size class
	/// - returns: Spacing for a given block
	func blockSpacing(for: BlockNode, horizontalSizeClass: UserInterfaceSizeClass) -> BlockSpacing
}
