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

	public func foldingAttributes(parentAttributes parentAttributes: Attributes) -> Attributes {
		var attributes = parentAttributes
		attributes[NSForegroundColorAttributeName] = foldedColor
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
			case .one:
				attributes[NSForegroundColorAttributeName] = headingOneColor
				attributes[NSFontAttributeName] = fontOfSize(round(fontSize * 1.5), symbolicTraits: .TraitBold)
			case .two:
				attributes[NSForegroundColorAttributeName] = headingTwoColor
				attributes[NSFontAttributeName] = fontOfSize(round(fontSize * 1.2), symbolicTraits: .TraitBold)
			case .three:
				attributes[NSForegroundColorAttributeName] = headingThreeColor
				attributes[NSFontAttributeName] = fontOfSize(round(fontSize * 1.1), symbolicTraits: .TraitBold)
			case .four:
				attributes[NSForegroundColorAttributeName] = headingFourColor
				attributes[NSFontAttributeName] = fontOfSize(fontSize, symbolicTraits: .TraitBold)
			case .five:
				attributes[NSForegroundColorAttributeName] = headingFiveColor
			case .six:
				attributes[NSForegroundColorAttributeName] = headingSixColor
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

	public func attributes(span span: SpanNode, parentAttributes: Attributes) -> Attributes? {
		guard let currentFont = parentAttributes[NSFontAttributeName] as? X.Font else { return nil }
		var traits = currentFont.symbolicTraits
		var attributes = parentAttributes
		let fontSize = currentFont.pointSize

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
		
		return attributes
	}
}
