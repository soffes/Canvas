//
//  AnnotationsController.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasNative

protocol AnnotationsControllerDelegate: class {
	func annotationsController(annotationsController: AnnotationsController, willAddAnnotation annotation: Annotation)
}

final class AnnotationsController {

	// MARK: - Properties

	var enabled = true

	var theme: Theme {
		didSet {
			for annotation in annotations {
				annotation?.theme = theme
			}
		}
	}

	var textContainerInset: EdgeInsets = .zero {
		didSet {
			layoutAnnotations()
		}
	}

	var horizontalSizeClass: UserInterfaceSizeClass = .Unspecified {
		didSet {
			for annotation in annotations {
				annotation?.horizontalSizeClass = horizontalSizeClass
			}
		}
	}

	weak var delegate: AnnotationsControllerDelegate?
	weak var textController: TextController?

	private var annotations = [Annotation?]()


	// MARK: - Initializers

	init(theme: Theme) {
		self.theme = theme
	}


	// MARK: - Manipulating

	func insert(block block: BlockNode, index: Int) {
		guard enabled, let block = block as? Annotatable, annotation = annotationForBlock(block) else {
			annotations.insert(nil, atIndex: index)
			return
		}

		annotation.view.frame = rectForAnnotation(annotation, index: index)
		annotations.insert(annotation, atIndex: index)
		delegate?.annotationsController(self, willAddAnnotation: annotation)
	}

	func remove(block block: BlockNode, index: Int) {
		guard enabled && index < annotations.count else { return }

		annotations[index]?.view.removeFromSuperview()
		annotations.removeAtIndex(index)
	}

	func replace(block block: BlockNode, index: Int) {
		guard enabled && index < annotations.count else { return }
		update(block: block, index: index)
	}

	func update(block block: BlockNode, index: Int) {
		guard enabled && index < annotations.count, let block = block as? Annotatable, annotation = annotations[index] else { return }
		annotation.block = block
		annotation.view.frame = rectForAnnotation(annotation, index: index)
	}


	// MARK: - Layout

	func layoutAnnotations() {
		for (index, annotation) in annotations.enumerate() {
			guard let annotation = annotation else { continue }
			annotation.view.frame = rectForAnnotation(annotation, index: index)
		}
	}

	func rectForAnnotation(annotation: Annotation, index: Int) -> CGRect {
		guard let textController = textController else { return .zero }

		let presentationRange = textController.documentController.document.presentationRange(backingRange: annotation.block.enclosingRange)
		let glyphIndex = textController.layoutManager.glyphIndexForCharacterAtIndex(presentationRange.location)
		var rect = textController.layoutManager.lineFragmentUsedRectForGlyphAtIndex(glyphIndex, effectiveRange: nil, withoutAdditionalLayout: true)

		switch annotation.style {
		case .LeadingGutter:
			// Make the annotation the width of the indentation. It's up to the view to position itself inside this space.
			// A future optimization could be making this as small as possible. Configuring it to do this was consfusing,
			// so deferring for now.
			rect.size.width = rect.origin.x
			rect.origin.x = 0

		case .Background:
			rect.origin.x = 0
			rect.size.width = textController.textContainer.size.width
		}

		rect.origin.x += textContainerInset.left
		rect.origin.y += textContainerInset.top

		// Account for line height
		// TODO: We should get this a better way
		rect.origin.y += 2

		return rect.integral
	}


	// MARK: - Private

	private func annotationForBlock(block: Annotatable) -> Annotation? {
		return block.annotation(theme: theme)
	}
}
