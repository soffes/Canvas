//
//  LightTheme.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import CanvasNative
import UIKit

public struct LightTheme: Theme {

	// MARK: - Properties

	public let fontSize: CGFloat = 18
	public let backgroundColor = UIColor(white: 1, alpha: 1)
	public let foregroundColor = UIColor(white: 0.133, alpha: 1)
	public let placeholderColor = Color(red: 0.847, green: 0.847, blue: 0.863, alpha: 1)
	public var tintColor = Color(red: 0.004, green: 0.412, blue: 1, alpha: 1)

	public var bulletColor: Color {
		return placeholderColor
	}

	public let blockquoteBorderColor = Color(red: 0.925, green: 0.925, blue: 0.929, alpha: 1)
	public let codeBackground = Color(red: 0.961, green: 0.961, blue: 0.965, alpha: 1)

	public let lineHeightMultiple: CGFloat = 1.2

	private let smallParagraphSpacing: CGFloat
	private let mediumGray = UIColor(red: 0.494, green: 0.494, blue: 0.510, alpha: 1)

	private var listIndentation: CGFloat {
		return round(fontSize * 1.1)
	}


	// MARK: - Initializers

	public init() {
		smallParagraphSpacing = fontSize * 0.1
	}


	// MARK: - Theme

	private var baseParagraph: NSMutableParagraphStyle {
		let paragraph = NSMutableParagraphStyle()
		paragraph.lineHeightMultiple = lineHeightMultiple
		return paragraph
	}

	public var baseAttributes: Attributes {
		return [
			NSForegroundColorAttributeName: foregroundColor,
			NSFontAttributeName: fontOfSize(fontSize),
			NSParagraphStyleAttributeName: baseParagraph
		]
	}

	public var foldingAttributes: Attributes {
		return [
			NSForegroundColorAttributeName: UIColor(red: 0.847, green: 0.847, blue: 0.863, alpha: 1)
		]
	}

	public var titleAttributes: Attributes {
		var attributes = baseAttributes
		attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
		attributes[NSFontAttributeName] = fontOfSize(fontSize * 1.7, symbolicTraits: .TraitBold)
		return attributes
	}

	public func blockSpacing(block block: BlockNode, horizontalSizeClass: UserInterfaceSizeClass) -> BlockSpacing {
		var spacing = BlockSpacing(marginBottom: fontSize * 1.5)

		// Large left padding on title for icon
		if block is Title {
			spacing.paddingLeft = 32
			return spacing
		}

		// No margin if it's not at the bottom of a positionable list
		if let block = block as? Positionable where !(block is Blockquote) {
			if !block.position.isBottom {
				spacing.marginBottom = 0
			}
		}

		// Heading spacing
		if block is Heading {
			spacing.marginTop = spacing.marginBottom * 0.25
			spacing.marginBottom /= 2
			return spacing
		}

		// Indentation
		if let listable = block as? Listable {
			spacing.paddingLeft = listIndentation * CGFloat(listable.indentation.rawValue + 1)
			return spacing
		}

		if let code = block as? CodeBlock {
			// Top margin
			if code.position.isTop {
				spacing.marginTop += 4
			}

			if code.position.isBottom {
				spacing.marginBottom += 4
			}

			// Indent
			if horizontalSizeClass == .Regular {
				// TODO: Use a constant
				spacing.paddingLeft = 48
			} else {
				spacing.paddingLeft = listIndentation
			}

			return spacing
		}

		if block is Blockquote {
			spacing.paddingLeft = listIndentation
			return spacing
		}

		return spacing
	}

	public func attributesForNode(node: Node, currentFont: CanvasText.Font?) -> Attributes {
		if node is Title {
			return titleAttributes
		}

		let fontSize = currentFont?.pointSize ?? self.fontSize

		var attributes = baseAttributes
		attributes[NSParagraphStyleAttributeName] = nil

		let paragraph = baseParagraph

		if let heading = node as? Heading {
			switch heading.level {
			case .One:
				attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
				attributes[NSFontAttributeName] = fontOfSize(fontSize * 1.5, symbolicTraits: .TraitBold)
			case .Two:
				attributes[NSForegroundColorAttributeName] = foregroundColor
				attributes[NSFontAttributeName] = fontOfSize(fontSize * 1.2, symbolicTraits: .TraitBold)
			case .Three:
				attributes[NSForegroundColorAttributeName] = UIColor(white: 0.3, alpha: 1)
				attributes[NSFontAttributeName] = fontOfSize(fontSize * 1.1, symbolicTraits: .TraitBold)
			case .Four:
				attributes[NSForegroundColorAttributeName] = mediumGray
				attributes[NSFontAttributeName] = fontOfSize(fontSize, symbolicTraits: .TraitBold)
			case .Five:
				attributes[NSForegroundColorAttributeName] = mediumGray
			case .Six:
				attributes[NSForegroundColorAttributeName] = UIColor(white: 0.6, alpha: 1)
			}
		}

		else if node is CodeBlock {
			attributes[NSForegroundColorAttributeName] = mediumGray
			attributes[NSFontAttributeName] = monospaceFontOfSize(fontSize)

			paragraph.headIndent = fontSize
		}

		else if node is Blockquote {
			attributes[NSForegroundColorAttributeName] = mediumGray
		}

		else if node is CodeSpan {
			let traits = currentFont?.fontDescriptor().symbolicTraits ?? []
			attributes[NSFontAttributeName] = monospaceFontOfSize(fontSize, symbolicTraits: traits)
			attributes[NSForegroundColorAttributeName] = UIColor(red: 0.494, green: 0.494, blue: 0.510, alpha: 1)
			attributes[NSBackgroundColorAttributeName] = UIColor(red: 0.961, green: 0.961, blue: 0.965, alpha: 1)
		}

		else if node is DoubleEmphasis {
			var traits = currentFont?.fontDescriptor().symbolicTraits ?? []
			traits.insert(.TraitBold)

			attributes[NSFontAttributeName] = fontOfSize(fontSize, symbolicTraits: traits)
		}

		else if node is Emphasis {
			var traits = currentFont?.fontDescriptor().symbolicTraits ?? []
			traits.insert(.TraitItalic)

			attributes[NSFontAttributeName] = fontOfSize(fontSize, symbolicTraits: traits)
		}

		else if node is Link {
			attributes[NSForegroundColorAttributeName] = tintColor
		}

		if node is BlockNode {
			attributes[NSParagraphStyleAttributeName] = paragraph
		}
		
		return attributes
	}
}
