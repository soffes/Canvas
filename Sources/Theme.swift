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

public typealias Attributes = [String: AnyObject]

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


	/// MARK: - Fonts

	/// Base font size
	var fontSize: CGFloat { get }

	/// Get a font for given size and traits
	///
	/// - parameter fontSize: Font size in points
	/// - parameter symbolicTraits: Traits to use for the font
	/// - returns: A font with given font size and traits
	func fontOfSize(fontSize: CGFloat, symbolicTraits: FontDescriptorSymbolicTraits) -> Font

	/// Get a monospace font for given size and traits
	///
	/// - parameter fontSize: Font size in points
	/// - parameter symbolicTraits: Traits to use for the font
	/// - returns: A monospace font with given font size and traits
	func monospaceFontOfSize(fontSize: CGFloat, symbolicTraits: FontDescriptorSymbolicTraits) -> Font


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
	func attributes(block block: BlockNode) -> Attributes

	/// Attributes for a span
	///
	/// NSFontAttributeName must be present.
	///
	/// - parameter block: Span node to style
	/// - parameter currentFont: Font of the parent node
	/// - returns: Attributes for given block
	func attributes(span span: SpanNode, currentFont: Font) -> Attributes?

	/// Attributes for a folded range.
	///
	/// NSFontAttributeName must be present.
	///
	/// - parameter currentFont: Font of the parent node
	/// - returns: Attributes for given block
	func foldingAttributes(currentFont currentFont: Font) -> Attributes

	/// Calculate spacing for a given block.
	///
	/// - parameter block: Block to layout
	/// - parameter horizontalSizeClass: Horizontal size class
	/// - returns: Spacing for a given block
	func blockSpacing(block block: BlockNode, horizontalSizeClass: UserInterfaceSizeClass) -> BlockSpacing
}


extension Theme {
	public var fontSize: CGFloat {
		return 18
	}

	private var listIndentation: CGFloat {
		return round(fontSize * 1.1)
	}

	public var baseAttributes: Attributes {
		return [
			NSForegroundColorAttributeName: foregroundColor,
			NSFontAttributeName: fontOfSize(fontSize)
		]
	}

	public var titleAttributes: Attributes {
		var attributes = baseAttributes
		attributes[NSForegroundColorAttributeName] = foregroundColor
		attributes[NSFontAttributeName] = fontOfSize(round(fontSize * 1.7), symbolicTraits: [.TraitBold])
		return attributes
	}

	public func foldingAttributes(currentFont currentFont: X.Font) -> Attributes {
		var attributes = baseAttributes
		attributes[NSForegroundColorAttributeName] = foldedColor
		attributes[NSFontAttributeName] = currentFont
		return attributes
	}

	public func fontOfSize(fontSize: CGFloat, symbolicTraits: FontDescriptorSymbolicTraits = []) -> Font {
		let font = Font.systemFontOfSize(fontSize)

		if !symbolicTraits.isEmpty {
			#if os(OSX)
				let fontManager = NSFontManager()
				var output = font

				if symbolicTraits.contains(.TraitBold) {
					output = fontManager.fontWithFamily(font.familyName!, traits: [], weight: 8, size: output.pointSize) ?? output
				}

				if symbolicTraits.contains(.TraitItalic) {
					output = fontManager.convertFont(output, toHaveTrait: .ItalicFontMask)
				}

				return output
			#else
				let descriptor = font.fontDescriptor().fontDescriptorWithSymbolicTraits(symbolicTraits)
				return Font(descriptor: descriptor, size: font.pointSize)
			#endif
		}

		return font
	}

	public func monospaceFontOfSize(fontSize: CGFloat, symbolicTraits: FontDescriptorSymbolicTraits = []) -> Font {
		guard let font = Font(name: "Menlo", size: fontSize) else {
			return fontOfSize(fontSize, symbolicTraits: symbolicTraits)
		}

		#if !os(OSX)
			if !symbolicTraits.isEmpty {
				let descriptor = font.fontDescriptor().fontDescriptorWithSymbolicTraits(symbolicTraits)
				return Font(descriptor: descriptor, size: font.pointSize) ?? font
			}
		#endif

		return font
	}

	public func blockSpacing(block block: BlockNode, horizontalSizeClass: UserInterfaceSizeClass) -> BlockSpacing {
		var spacing = BlockSpacing(marginBottom: round(fontSize * 1.5))

		// No margin if it's not at the bottom of a positionable list
		if let block = block as? Positionable where !(block is Blockquote) {
			if !block.position.isBottom {
				spacing.marginBottom = 4
			}
		}

		// Heading spacing
		if block is Heading {
			spacing.marginTop = round(spacing.marginBottom * 0.25)
			spacing.marginBottom = round(spacing.marginBottom / 2)
			return spacing
		}

		// Indentation
		if let listable = block as? Listable {
			spacing.paddingLeft = round(listIndentation * CGFloat(listable.indentation.rawValue + 1))
			return spacing
		}

		if let code = block as? CodeBlock {
			let padding: CGFloat = 16
			let margin: CGFloat = 5

			// Top margin
			if code.position.isTop {
				spacing.paddingTop += padding
				spacing.marginTop += margin
			}

			// Bottom margin
			if code.position.isBottom {
				spacing.paddingBottom += padding
				spacing.marginBottom += margin
			}

			spacing.paddingLeft = listIndentation

			// Indent for line numbers
			if horizontalSizeClass == .Regular {
				// TODO: Don't hard code
				spacing.paddingLeft += 40
			}

			return spacing
		}

		if let blockquote = block as? Blockquote {
			let padding: CGFloat = 4

			// Top margin
			if blockquote.position.isTop {
				spacing.paddingTop += padding
			}

			// Bottom margin
			if blockquote.position.isBottom {
				spacing.paddingBottom += padding
			}

			spacing.paddingLeft = listIndentation

			return spacing
		}

		return spacing
	}

	public func attributes(block block: BlockNode) -> Attributes {
		if block is Title {
			return titleAttributes
		}

		var attributes = baseAttributes

		if let heading = block as? Heading {
			switch heading.level {
			case .One:
				attributes[NSForegroundColorAttributeName] = foregroundColor
				attributes[NSFontAttributeName] = fontOfSize(round(fontSize * 1.5), symbolicTraits: .TraitBold)
			case .Two:
				attributes[NSForegroundColorAttributeName] = foregroundColor
				attributes[NSFontAttributeName] = fontOfSize(round(fontSize * 1.2), symbolicTraits: .TraitBold)
			case .Three:
				attributes[NSForegroundColorAttributeName] = foregroundColor
				attributes[NSFontAttributeName] = fontOfSize(round(fontSize * 1.1), symbolicTraits: .TraitBold)
			case .Four:
				attributes[NSForegroundColorAttributeName] = foregroundColor
				attributes[NSFontAttributeName] = fontOfSize(fontSize, symbolicTraits: .TraitBold)
			case .Five:
				attributes[NSForegroundColorAttributeName] = foregroundColor
			case .Six:
				attributes[NSForegroundColorAttributeName] = foregroundColor
			}
		}

		else if block is CodeBlock {
			attributes[NSForegroundColorAttributeName] = codeColor
			attributes[NSFontAttributeName] = monospaceFontOfSize(fontSize)

			// Indent wrapped lines in code blocks
			let paragraph = NSMutableParagraphStyle()
			paragraph.headIndent = floor(fontSize * 1.2) + 0.5
			attributes[NSParagraphStyleAttributeName] = paragraph
		}

		else if block is Blockquote {
			attributes[NSForegroundColorAttributeName] = blockquoteColor
		}

		return attributes
	}

	public func attributes(span span: SpanNode, currentFont: X.Font) -> Attributes? {
		var traits = currentFont.symbolicTraits
		var attributes = Attributes()

		if span is CodeSpan {
			attributes[NSFontAttributeName] = monospaceFontOfSize(fontSize, symbolicTraits: traits)
			attributes[NSForegroundColorAttributeName] = codeSpanColor
			attributes[NSBackgroundColorAttributeName] = codeSpanBackgroundColor
		}

		else if span is Strikethrough {
			attributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.StyleThick.rawValue
			attributes[NSStrikethroughColorAttributeName] = strikethroughColor
			attributes[NSForegroundColorAttributeName] = strikethroughColor
		}

		else if span is DoubleEmphasis {
			traits.insert(.TraitBold)
			attributes[NSFontAttributeName] = fontOfSize(fontSize, symbolicTraits: traits)
		}

		else if span is Emphasis {
			traits.insert(.TraitItalic)
			attributes[NSFontAttributeName] = fontOfSize(fontSize, symbolicTraits: traits)
		}

		else if span is Link {
			attributes[NSForegroundColorAttributeName] = tintColor
		}

		// If there aren't any attributes set yet, return nil and inherit from parent.
		if attributes.isEmpty {
			return nil
		}

		// Ensure a font is set
		if attributes[NSFontAttributeName] == nil {
			attributes[NSFontAttributeName] = currentFont
		}
		
		return attributes
	}
}
