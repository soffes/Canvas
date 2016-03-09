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

public typealias Attributes = [String: AnyObject]

public protocol Theme {

	var fontSize: CGFloat { get }

	var backgroundColor: Color { get }
	var foregroundColor: Color { get }
	var placeholderColor: Color { get }
	var tintColor: Color { get set }
	var foldingAttributes: Attributes { get }
	var baseAttributes: Attributes { get }
	var titleAttributes: Attributes { get }

	var bulletColor: Color { get }
	var blockquoteBorderColor: Color { get }
	var codeBackground: Color { get }

	var lineHeightMultiple: CGFloat { get }

	func fontOfSize(fontSize: CGFloat, symbolicTraits: FontDescriptorSymbolicTraits) -> Font
	func monospaceFontOfSize(fontSize: CGFloat, symbolicTraits: FontDescriptorSymbolicTraits) -> Font

	func attributesForNode(node: Node, currentFont: Font?) -> Attributes

	func blockSpacing(block block: BlockNode, horizontalSizeClass: UserInterfaceSizeClass) -> BlockSpacing
}


extension Theme {
	public var foldingAttributes: Attributes {
		return [
			NSForegroundColorAttributeName: placeholderColor
		]
	}

	public var baseAttributes: Attributes {
		return [
			NSForegroundColorAttributeName: foregroundColor,
			NSFontAttributeName: fontOfSize(fontSize)
		]
	}

	public var titleAttributes: Attributes {
		return baseAttributes
	}

	public func fontOfSize(fontSize: CGFloat, symbolicTraits: FontDescriptorSymbolicTraits = []) -> Font {
		let font = Font.systemFontOfSize(fontSize)

		#if !os(OSX)
			if !symbolicTraits.isEmpty {
				let descriptor = font.fontDescriptor().fontDescriptorWithSymbolicTraits(symbolicTraits)
				return Font(descriptor: descriptor, size: font.pointSize)
			}
		#endif

		return font
	}

	public func monospaceFontOfSize(fontSize: CGFloat, symbolicTraits: FontDescriptorSymbolicTraits = []) -> Font {
		guard let font = Font(name: "Menlo", size: fontSize) else {
			return fontOfSize(fontSize, symbolicTraits: symbolicTraits)
		}

		#if !os(OSX)
			if !symbolicTraits.isEmpty {
				let descriptor = font.fontDescriptor().fontDescriptorWithSymbolicTraits(symbolicTraits)
				return Font(descriptor: descriptor, size: font.pointSize)
			}
		#endif

		return font
	}
}
