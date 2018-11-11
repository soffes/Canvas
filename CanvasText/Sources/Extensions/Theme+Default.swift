#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import CanvasNative
import X

extension Theme {
	public var fontSize: CGFloat {
		return UIFont.preferredFont(forTextStyle: .body).pointSize
	}

	private var listIndentation: CGFloat {
		let font = UIFont.preferredFont(forTextStyle: .body)
		return ("     " as NSString).size(withAttributes: [.font: font]).width
	}

	public var baseAttributes: Attributes {
		return [
			.foregroundColor: foregroundColor,
			.font: TextStyle.body.font()
		]
	}

	public var titleAttributes: Attributes {
		var attributes = baseAttributes
		attributes[.foregroundColor] = foregroundColor
		attributes[.font] = TextStyle.title1.font(weight: .semibold)
		return attributes
	}

	public func foldingAttributes(withParentAttributes parentAttributes: Attributes) -> Attributes {
		var attributes = parentAttributes
		attributes[.foregroundColor] = foldedColor
		return attributes
	}

	public func blockSpacing(for block: BlockNode, horizontalSizeClass: UserInterfaceSizeClass) -> BlockSpacing {
		var spacing = BlockSpacing(marginBottom: round(fontSize * 1.5))

		// No margin if it's not at the bottom of a positionable list
		if let block = block as? Positionable, !(block is Blockquote) {
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
			let padding: CGFloat = 8
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

			spacing.paddingLeft = padding * 2

			// Indent for line numbers
			if horizontalSizeClass == .regular {
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

	public func attributes(for block: BlockNode) -> Attributes {
		if block is Title {
			return titleAttributes
		}

		var attributes = baseAttributes

		if let heading = block as? Heading {
			switch heading.level {
			case .one:
				attributes[.foregroundColor] = headingOneColor
				attributes[.font] = TextStyle.title1.font(weight: .medium)
			case .two:
				attributes[.foregroundColor] = headingTwoColor
				attributes[.font] = TextStyle.title2.font(weight: .medium)
			case .three:
				attributes[.foregroundColor] = headingThreeColor
				attributes[.font] = TextStyle.title3.font(weight: .medium)
			case .four:
				attributes[.foregroundColor] = headingFourColor
				attributes[.font] = TextStyle.headline.font(weight: .medium)
			case .five:
				attributes[.foregroundColor] = headingFiveColor
				attributes[.font] = TextStyle.headline.font(weight: .medium)
			case .six:
				attributes[.foregroundColor] = headingSixColor
				attributes[.font] = TextStyle.headline.font(weight: .medium)
			}
		} else if block is CodeBlock {
			attributes[.foregroundColor] = codeColor
			attributes[.font] = TextStyle.body.monoSpaceFont()

			// Indent wrapped lines in code blocks
			let paragraph = NSMutableParagraphStyle()
			paragraph.headIndent = floor(fontSize * 1.2) + 0.5
			attributes[.paragraphStyle] = paragraph
		} else if block is Blockquote {
			attributes[.foregroundColor] = blockquoteColor
		}

		return attributes
	}

	public func attributes(for span: SpanNode, parentAttributes: Attributes) -> Attributes? {
		guard let currentFont = parentAttributes[.font] as? X.Font else {
            return nil
        }
		var traits = currentFont.symbolicTraits
		var attributes = parentAttributes

		if span is CodeSpan {
			let monoSpaceFont = UIFont(name: "Menlo", size: currentFont.pointSize * 0.9)!
			let font = applySymbolicTraits(traits, toFont: monoSpaceFont)
			attributes[.font] = font
			attributes[.foregroundColor] = codeSpanColor
			attributes[.backgroundColor] = codeSpanBackgroundColor
		} else if span is Strikethrough {
			attributes[.strikethroughStyle] = NSUnderlineStyle.thick.rawValue
			attributes[.strikethroughColor] = strikethroughColor
			attributes[.foregroundColor] = strikethroughColor
		} else if span is DoubleEmphasis {
			traits.insert(.traitBold)
			attributes[.font] = applySymbolicTraits(traits, toFont: currentFont)
		} else if span is Emphasis {
			traits.insert(.traitItalic)
			attributes[.font] = applySymbolicTraits(traits, toFont: currentFont)
		} else if span is Link {
			attributes[.foregroundColor] = tintColor
		}

		// If there aren't any attributes set yet, return nil and inherit from parent.
		if attributes.isEmpty {
			return nil
		}

		return attributes
	}
}
