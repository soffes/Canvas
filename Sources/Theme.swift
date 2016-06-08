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

	var fontSize: CGFloat { get }

	var backgroundColor: Color { get }
	var foregroundColor: Color { get }
	var placeholderColor: Color { get }
	var tintColor: Color { get set }
	var horizontalRuleColor: Color { get }
	var baseAttributes: Attributes { get }
	var titleAttributes: Attributes { get }

	var bulletColor: Color { get }
	var uncheckedCheckboxColor: Color { get }
	var orderedListItemNumberColor: Color { get }
	var codeColor: Color { get }
	var codeBlockBackgroundColor: Color { get }
	var codeBlockLineNumberColor: Color { get }
	var codeBlockLineNumberBackgroundColor: Color { get }
	var blockquoteColor: Color { get }
	var blockquoteBorderColor: Color { get }
	var strikethroughColor: Color { get }
	var commentBackgroundColor: Color { get }
	var linkURLColor: Color { get }

	var placeholderImageColor: Color { get }
	var placeholderImageBackgroundColor: Color { get }

	func fontOfSize(fontSize: CGFloat, symbolicTraits: FontDescriptorSymbolicTraits) -> Font
	func monospaceFontOfSize(fontSize: CGFloat, symbolicTraits: FontDescriptorSymbolicTraits) -> Font

	// NSFontAttributeName must be present.
	func attributes(block block: BlockNode) -> Attributes

	// NSFontAttributeName must be present.
	func attributes(span span: SpanNode, currentFont: Font) -> Attributes?

	// NSFontAttributeName must be present.
	func foldingAttributes(currentFont currentFont: Font) -> Attributes

	func blockSpacing(block block: BlockNode, horizontalSizeClass: UserInterfaceSizeClass) -> BlockSpacing
}


extension Theme {
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
}
