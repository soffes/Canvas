//
//  Theme+Default.swift
//  CanvasText
//
//  Created by Sam Soffes on 6/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import CanvasNative
import X

extension Theme {
	public var fontSize: CGFloat {
		return UIFont.preferredFontForTextStyle(UIFontTextStyleBody).pointSize
	}

	private var listIndentation: CGFloat {
		let font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
		return ("    " as NSString).sizeWithAttributes([NSFontAttributeName: font]).width
	}

	public var baseAttributes: Attributes {
		return [
			NSForegroundColorAttributeName: foregroundColor,
			NSFontAttributeName: TextStyle.Body.font()
		]
	}

	public var titleAttributes: Attributes {
		var attributes = baseAttributes
		attributes[NSForegroundColorAttributeName] = foregroundColor
		attributes[NSFontAttributeName] = TextStyle.Title1.font(weight: .Semibold)
		return attributes
	}

	public func foldingAttributes(parentAttributes parentAttributes: Attributes) -> Attributes {
		var attributes = parentAttributes
		attributes[NSForegroundColorAttributeName] = foldedColor
		return attributes
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
			case .one:
				attributes[NSForegroundColorAttributeName] = headingOneColor
				attributes[NSFontAttributeName] = TextStyle.Title1.font(weight: .Medium)
			case .two:
				attributes[NSForegroundColorAttributeName] = headingTwoColor
				attributes[NSFontAttributeName] = TextStyle.Title2.font(weight: .Medium)
			case .three:
				attributes[NSForegroundColorAttributeName] = headingThreeColor
				attributes[NSFontAttributeName] = TextStyle.Title3.font(weight: .Medium)
			case .four:
				attributes[NSForegroundColorAttributeName] = headingFourColor
				attributes[NSFontAttributeName] = TextStyle.Headline.font(weight: .Medium)
			case .five:
				attributes[NSForegroundColorAttributeName] = headingFiveColor
				attributes[NSFontAttributeName] = TextStyle.Headline.font(weight: .Medium)
			case .six:
				attributes[NSForegroundColorAttributeName] = headingSixColor
				attributes[NSFontAttributeName] = TextStyle.Headline.font(weight: .Medium)
			}
		}

		else if block is CodeBlock {
			attributes[NSForegroundColorAttributeName] = codeColor
			attributes[NSFontAttributeName] = TextStyle.Body.monoSpaceFont()

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

	public func attributes(span span: SpanNode, parentAttributes: Attributes) -> Attributes? {
		guard let currentFont = parentAttributes[NSFontAttributeName] as? X.Font else { return nil }
		var traits = currentFont.symbolicTraits
		var attributes = parentAttributes

		if span is CodeSpan {
			let monoSpaceFont = UIFont(name: "Menlo", size: currentFont.pointSize * 0.9)!
			let font = applySymbolicTraits(traits, toFont: monoSpaceFont)
			attributes[NSFontAttributeName] = font
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
			attributes[NSFontAttributeName] = applySymbolicTraits(traits, toFont: currentFont)
		}

		else if span is Emphasis {
			traits.insert(.TraitItalic)
			attributes[NSFontAttributeName] = applySymbolicTraits(traits, toFont: currentFont)
		}

		else if span is Link {
			attributes[NSForegroundColorAttributeName] = tintColor
		}

		// If there aren't any attributes set yet, return nil and inherit from parent.
		if attributes.isEmpty {
			return nil
		}
		
		return attributes
	}
}
