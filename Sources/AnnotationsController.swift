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
	func annotationsController(annotationsController: AnnotationsController, willAddAnnotation annotation: View)
}

final class AnnotationsController {

	// MARK: - Properties

	// TODO: Update theme on all annotations
	var theme: Theme

	weak var delegate: AnnotationsControllerDelegate?

	private var annotations = [View]()


	// MARK: - Initializers

	init(theme: Theme) {
		self.theme = theme
	}


	// MARK: - Manipulating

	func insert(block block: BlockNode, index: Int) {
		let annotation = annotationForBlock(block)
		annotation.frame = rectForAnnotation(annotation, index: index)
		annotations.insert(annotation, atIndex: index)
		delegate?.annotationsController(self, willAddAnnotation: annotation)
	}

	func remove(block block: BlockNode, index: Int) {
		annotations.removeAtIndex(index)
	}

	func replace(block block: BlockNode, index: Int) {
		update(block: block, index: index)
	}

	func update(block block: BlockNode, index: Int) {
		let annotation = annotations[index]
		annotation.frame = rectForAnnotation(annotation, index: index)
	}


	// MARK: - Layout

	func layoutAnnotations() {
		for (index, annotation) in annotations.enumerate() {
			annotation.frame = rectForAnnotation(annotation, index: index)
		}
	}

	func rectForAnnotation(annotation: View, index: Int) -> CGRect {
		// TODO: Implement
		return CGRect(x: 16, y: 64+16, width: 8, height: 8)
	}


	// MARK: - Private

	private func annotationForBlock(block: BlockNode) -> View {
		if let unorderedListItem = block as? UnorderedListItem {
			return BulletView(theme: theme, unorderedList: unorderedListItem)
		}

		// TODO: Implement additional types

		return View()
	}
}
