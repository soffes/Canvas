//
//  LayoutManager.swift
//  CanvasText
//
//  Created by Sam Soffes on 1/22/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import CanvasNative

protocol LayoutManagerDelegate: class {
	func layoutManagerDidInvalidateGlyphs(layoutManager: NSLayoutManager)
	func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer)
}

/// All ranges are presentation ranges.
class LayoutManager: NSLayoutManager {

	// MARK: - Properties

	weak var textController: TextController?
	weak var layoutDelegate: LayoutManagerDelegate?

	var unfoldedRange: NSRange? {
		didSet {
			if let unfoldedRange = unfoldedRange, oldValue = oldValue where !unfoldedRange.equals(oldValue) {
				unfolding = true
				invalidateGlyphs()
				return
			}

			if let unfoldedRange = unfoldedRange {
				unfolding = !foldedIndices.intersect(unfoldedRange.indices).isEmpty
			} else {
				unfolding = false
			}

			invalidateGlyphsIfNeeded()
		}
	}

	private var foldableRanges = [NSRange]() {
		didSet {
			let indicies = foldableRanges.map { $0.indices }
			foldedIndices = Set(indicies.flatten())

			invalidateGlyphs()
		}
	}

	private var needsInvalidateGlyphs = false
	private var foldedIndices = Set<Int>()
	private var unfolding = false {
		didSet {
			guard unfolding != oldValue else { return }
			setNeedsInvalidateGlyphs()
		}
	}


	// MARK: - Initializers

	override init() {
		super.init()
		delegate = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - Private

	// TODO: We should intellegently invalidate glyphs are a given range instead of the entire document.
	private func invalidateGlyphs() {
		guard let characterLength = textStorage?.length else { return }
		let characterRange = NSRange(location: 0, length: characterLength)
		invalidateGlyphsForCharacterRange(characterRange, changeInLength: 0, actualCharacterRange: nil)
		layoutDelegate?.layoutManagerDidInvalidateGlyphs(self)
		needsInvalidateGlyphs = false
	}

	private func setNeedsInvalidateGlyphs() {
		needsInvalidateGlyphs = true
	}

	private func invalidateGlyphsIfNeeded() {
		if needsInvalidateGlyphs {
			invalidateGlyphs()
		}
	}
}


extension LayoutManager: NSLayoutManagerDelegate {
	func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
		guard let textContainer = textContainer else { return }
		layoutDelegate?.layoutManager(self, didCompleteLayoutForTextContainer: textContainer)
	}
}


#if os(iOS)
	extension LayoutManager {
		func layoutManager(layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSGlyphProperty>, characterIndexes: UnsafePointer<Int>, font: UIFont, forGlyphRange glyphRange: NSRange) -> Int {
			let properties = UnsafeMutablePointer<NSGlyphProperty>(props)

			for i in 0..<glyphRange.length {
				let characterIndex = characterIndexes[i]

				if !(unfoldedRange?.contains(characterIndex) ?? false) && foldedIndices.contains(characterIndex) {
					properties[i] = .ControlCharacter
				}
			}

			layoutManager.setGlyphs(glyphs, properties: properties, characterIndexes: characterIndexes, font: font, forGlyphRange: glyphRange)
			return glyphRange.length
		}

		func layoutManager(layoutManager: NSLayoutManager, shouldUseAction action: NSControlCharacterAction, forControlCharacterAtIndex characterIndex: Int) -> NSControlCharacterAction {
			// Don't advance if it's a control character we changed
			if foldedIndices.contains(characterIndex) {
				return .ZeroAdvancement
			}

			// Default action for things we didn't change
			return action
		}

		func layoutManager(layoutManager: NSLayoutManager, paragraphSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
			guard let textController = textController else { return 0 }

			let characterIndex = characterIndexForGlyphAtIndex(glyphIndex)
			guard let block = textController.canvasController.blockAt(presentationLocation: characterIndex) else { return 0 }

			return textController.theme.blockSpacing(block: block, horizontalSizeClass: textController.horizontalSizeClass).marginBottom
		}
	}
#endif
