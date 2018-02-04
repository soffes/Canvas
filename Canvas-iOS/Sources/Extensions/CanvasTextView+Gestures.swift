import CanvasNative
import UIKit

extension CanvasTextView {
	func registerGestureRecognizers() {
		dragGestureRecognizer.addTarget(self, action: #selector(pan))
		dragGestureRecognizer.delegate = self
		addGestureRecognizer(dragGestureRecognizer)
	}

	@objc private func pan(sender: UIPanGestureRecognizer) {
		switch sender.state {
		case .possible: return
		case .began: dragBegan()
		case .changed: dragChanged()
		case .ended: dragEnded(applyAction: true)
		case .cancelled, .failed: dragEnded(applyAction: false)
		}
	}

	private func dragBegan() {
		guard let context = dragContext else {
	    	return
    	}

		let contentView = context.contentView
		contentView.frame = CGRect(
			x: 0,
			y: context.rect.origin.y,
			width: bounds.width,
			height: context.rect.height
		)
		addSubview(contentView)
	}

	private func dragChanged() {
		guard var context = dragContext else {
	    	return
    	}

		var translation = dragGestureRecognizer.translation(in: self).x

		// Prevent dragging h1s left
		if let heading = context.block as? Heading, heading.level == .two {
			translation = max(0, translation)
		}

		// Prevent dragging lists right at the end
		else if let listItem = context.block as? Listable, listItem.indentation.isMaximum {
			translation = min(0, translation)
		}

		context.translate(x: translation)

		// Calculate block level
		if translation >= dragThreshold {
			context.dragAction = .increase
		} else if translation <= -dragThreshold {
			context.dragAction = .decrease
		} else {
			context.dragAction = nil
		}

		dragContext = context
	}

	private func dragEnded(applyAction: Bool) {
		guard let context = dragContext else {
	    	return
    	}

		UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
			context.translate(x: 0)
		}, completion: { [weak self] _ in
			if applyAction, let action = self?.dragContext?.dragAction, let textController = self?.textController {
				switch action {
				case .increase:
					textController.increaseBlockLevel(block: context.block)
				case .decrease:
					textController.decreaseBlockLevel(block: context.block)
				}
			}

			UIView.animate(withDuration: 0.15, animations: {
				context.contentView.alpha = 0
			}, completion: { _ in
				context.tearDown()
				self?.dragContext = nil
			})
		})
	}

	private func blockAt(point: CGPoint) -> BlockNode? {
		guard let document = textController?.currentDocument else {
			return nil
		}

		// Adjust point into layout manager's coordinates
		var point = point
		point.x -= contentInset.left
		point.x -= textContainerInset.left
		point.y -= contentInset.top
		point.y -= textContainerInset.top

		let location = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

		// Special case the last block
		if location > (document.presentationString as NSString).length - 2 {
			return document.blocks.last
		}

		return document.blockAt(presentationLocation: location, direction: .leading)
	}
}

extension CanvasTextView: UIGestureRecognizerDelegate {
	override func gestureRecognizerShouldBegin(_ sender: UIGestureRecognizer) -> Bool {
		// Make sure we don't mess with internal UITextView gesture recognizers.
		guard sender == dragGestureRecognizer, let textController = textController else {
			return super.gestureRecognizerShouldBegin(sender)
		}

		// If there are multiple characters selected, disable the drag since the text view uses that event to adjust the
		// selection.
		if selectedRange.length > 0 {
			return false
		}

		// Ensure it's a horizontal drag
		let velocity = dragGestureRecognizer.velocity(in: self)
		if abs(velocity.y) > abs(velocity.x) {
			return false
		}

		// Get the block
		let point = dragGestureRecognizer.location(in: self)
		guard let block = blockAt(point: point) else {
			return false
		}

		// Disable dragging if unsupported
		if !(block is Paragraph) && !(block is Heading) && !(block is Listable) {
			return false
		}

		// Dragging is only supported for h2 & h3
		if let block = block as? Heading, block.level != .two && block.level != .three {
			return false
		}

		// Get the block rect
		let characterRange = textController.currentDocument.presentationRange(block: block)
		let glyphRange = layoutManager.glyphRange(forCharacterRange: characterRange, actualCharacterRange: nil)
		var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
		rect.origin.x += textContainerInset.left
		rect.origin.y += textContainerInset.top

		// Snapshot
		let snapshotView = self.snapshotView(afterScreenUpdates: false)!

		// Setup context
		let context = DragContext(
			block: block,
			snapshotView: snapshotView,
			rect: rect.integral,
			yContentOffset: contentOffset.y
		)

		dragContext = context

		return true
	}
}
