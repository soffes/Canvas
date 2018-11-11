import CanvasText
import UIKit

class TextView: UITextView {

	// MARK: - Properties

	var managedSubviews = Set<UIView>()

	// MARK: - UIView

	// Allow subviews to receive user input
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		for view in managedSubviews {
			if view.superview == self && view.isUserInteractionEnabled && view.frame.contains(point) {
				return view
			}
		}

		return super.hitTest(point, with: event)
	}

	// MARK: - UITextInput

	// Only display the caret in the used rect (if available).
	override func caretRect(for position: UITextPosition) -> CGRect {
		var rect = super.caretRect(for: position)

		if let layoutManager = textContainer.layoutManager {
			layoutManager.ensureLayout(for: textContainer)

			let characterIndex = offset(from: beginningOfDocument, to: position)
			if characterIndex == textStorage.length {
				return rect
			}

			let glyphIndex = layoutManager.glyphIndexForCharacter(at: characterIndex)

			if UInt(glyphIndex) == UInt.max - 1 {
				return rect
			}

			let usedRect = layoutManager.lineFragmentUsedRect(forGlyphAt: glyphIndex, effectiveRange: nil)

			if usedRect.height > 0 {
				rect.origin.y = usedRect.minY + textContainerInset.top
				rect.size.height = usedRect.height
			}
		}

		return rect
	}

	// Omit empty width rect when drawing selection rects.
	override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
		let selectionRects = super.selectionRects(for: range)
		return selectionRects.filter { selection in
			return selection.rect.size.width > 0
		}
	}

	func rects(for range: NSRange) -> [CGRect] {
		// Become first responder if we aren't already. The text view has to be first responder for any of the position
		// or text range APIs to work. Annoying :(
		let wasFirstResponder = isFirstResponder
		if !wasFirstResponder {
			becomeFirstResponder()
		}

		// Get starting position
		guard let start = position(from: beginningOfDocument, offset: range.location) else {
			if !wasFirstResponder {
				resignFirstResponder()
			}
			return []
		}

		// Empty selection
		if range.length == 0 {
			if !wasFirstResponder {
				resignFirstResponder()
			}
			return [caretRect(for: start)]
		}

		// Selection
		guard let end = position(from: start, offset: range.length),
			let textRange = textRange(from: start, to: end),
			let selectionRects = (super.selectionRects(for: textRange) as? [UITextSelectionRect])?.map({ $0.rect }),
			let firstRect = selectionRects.first
		else {
			// Use extra line if there aren't any rects
			var rect = layoutManager.extraLineFragmentUsedRect
			rect.origin.x += textContainerInset.left
			rect.origin.y += textContainerInset.top

			if !wasFirstResponder {
				resignFirstResponder()
			}

			return [rect]
		}

		if !wasFirstResponder {
			resignFirstResponder()
		}

		let filtered = selectionRects.filter { $0.width > 0 }

		if filtered.isEmpty {
			return [firstRect]
		}

		return filtered
	}
}
