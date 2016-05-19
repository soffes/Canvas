//
//  LayoutManager.swift
//  CanvasText
//
//  Created by Sam Soffes on 1/22/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasNative

protocol LayoutManagerDelegate: class {
	// Used so the TextController can relayout annotations and attachments if the text view changes its bounds (and
	// as a result changes the text container's geometry).
	func layoutManager(layoutManager: NSLayoutManager, textContainerChangedGeometry textContainer: NSTextContainer)
}

/// Custom layout manager to handle proper line spacing and folding. This must be its own delegate.
///
/// The TextController will manage updating `foldableRanges`. This will be all ranges that should be folded. It will
/// also update `unfoldedRange`. This is the range that should be excluded from folding. It will drive this value based
/// on the user's selection.
///
/// All ranges are presentation ranges.
class LayoutManager: NSLayoutManager {

	// MARK: - Properties

	weak var textController: TextController?
	weak var layoutDelegate: LayoutManagerDelegate?

	private let foldingEnabled = true

	/// The user selection. Adjacent foldings should be unfolded.
	var presentationSelectedRange: NSRange? {
		didSet {
			guard foldingEnabled else { return }

			// TODO: Implement

//			dispatch_async(dispatch_get_main_queue()) { [weak self] in
//				self?.invalidateFoldableGlyphsIfNeeded()
//				self?.updateTextContainerIfNeeded()
//			}
		}
	}

	/// Folded ranges. Whenever this changes, it will trigger an invalidation of foldable glyphs.
	private var foldableRanges = [NSRange]() {
		didSet {
			let indicies = foldableRanges.map { $0.indices }
			foldedIndices = Set(indicies.flatten())
			setNeedsInvalidateFoldableGlyphs()
		}
	}

	/// If changes have been made to folding, we need to update the text container after it finishes its layout to apply
	/// the changes.
	private var needsUpdateTextContainer = false

	/// If changes have been made to folding, we need to invalid the layout manager's glyphs for that range and
	/// recalculate them so we can control which are marked as control characters with zero advancement.
	private var needsInvalidateFoldableGlyphs = false

	/// Set of indices that should be folded. Calculated from `foldableRanges`.
	private var foldedIndices = Set<Int>()


	// MARK: - Initializers

	override init() {
		super.init()
		allowsNonContiguousLayout = true
		delegate = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - NSLayoutManager

	override func textContainerChangedGeometry(container: NSTextContainer) {
		super.textContainerChangedGeometry(container)
		layoutDelegate?.layoutManager(self, textContainerChangedGeometry: container)
	}


	// MARK: - Invalidation

	func addFoldableRanges(presentationRanges: [NSRange]) {
		foldableRanges += presentationRanges
	}

	func clearFoldableRanges() {
		foldableRanges.removeAll()
	}


	// MARK: - Private

	private func setNeedsInvalidateFoldableGlyphs() {
		needsInvalidateFoldableGlyphs = true
	}

	private func invalidateFoldableGlyphsIfNeeded() {
		if needsInvalidateFoldableGlyphs {
			invalidateFoldableGlyphs()
		}
	}

	private func invalidateFoldableGlyphs() {
		guard foldingEnabled else { return }

		let sorted = foldableRanges.sort { $0.location < $1.location }
		guard let first = sorted.first, last = sorted.last else { return }

		let characterRange = NSRange(location: first.location, length: last.max - first.location)
		invalidateGlyphsForCharacterRange(characterRange, changeInLength: 0, actualCharacterRange: nil)
		needsInvalidateFoldableGlyphs = false
		needsUpdateTextContainer = true
	}

	private func updateTextContainerIfNeeded() {
		guard foldingEnabled && needsUpdateTextContainer, let textContainer = textController?.textContainer else { return }

		textContainer.replaceLayoutManager(self)
		needsUpdateTextContainer = false
	}
}


extension LayoutManager: NSLayoutManagerDelegate {
	// Mark folded characters as control characters so we can give them a zero width in
	// `layoutManager:shouldUseAction:forControlCharacterAtIndex:`.
	func layoutManager(layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSGlyphProperty>, characterIndexes: UnsafePointer<Int>, font: UIFont, forGlyphRange glyphRange: NSRange) -> Int {
		if !foldingEnabled || foldedIndices.isEmpty {
			return 0
		}

		let properties = UnsafeMutablePointer<NSGlyphProperty>(props)

		var changed = false
		for i in 0..<glyphRange.length {
			let characterIndex = characterIndexes[i]

			// Skip selected characters
//			if let selection = presentationSelectedRange where selection.contains(characterIndex) {
//				continue
//			}

			if foldedIndices.contains(characterIndex) {
				properties[i] = .ControlCharacter
				changed = true
			}
		}

		if !changed {
			return 0
		}

		layoutManager.setGlyphs(glyphs, properties: properties, characterIndexes: characterIndexes, font: font, forGlyphRange: glyphRange)
		return glyphRange.length
	}

	// Folded characters should have a zero width
	func layoutManager(layoutManager: NSLayoutManager, shouldUseAction action: NSControlCharacterAction, forControlCharacterAtIndex characterIndex: Int) -> NSControlCharacterAction {
		// Don't advance if it's a control character we changed
		if foldingEnabled && foldedIndices.contains(characterIndex) {
			return .ZeroAdvancement
		}

		// Default action for things we didn't change
		return action
	}

	// Adjust bottom margin of lines based on their block type
	func layoutManager(layoutManager: NSLayoutManager, paragraphSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
		guard let textController = textController else { return 0 }

		let characterIndex = characterIndexForGlyphAtIndex(glyphIndex)
		guard let block = textController.currentDocument.blockAt(presentationLocation: characterIndex) else { return 0 }

		return textController.theme.blockSpacing(block: block, horizontalSizeClass: textController.traitCollection.horizontalSizeClass).marginBottom
	}

	// If we've updated folding, we need to replace the layout manager in the text container. I'm all ears for a way to
	// avoid this.
	func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
		updateTextContainerIfNeeded()
	}
}
