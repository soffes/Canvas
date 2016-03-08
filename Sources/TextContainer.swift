//
//  TextContainer.swift
//  CanvasText
//
//  Created by Sam Soffes on 2/2/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import CanvasNative

class TextContainer: NSTextContainer {

	// MARK: - Properties

	weak var textController: TextController?


	// MARK: - Initializers

	override init(size: CGSize) {
		super.init(size: size)
		lineFragmentPadding = 0
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - NSTextContainer

	override func lineFragmentRectForProposedRect(proposedRect: CGRect, atIndex index: Int, writingDirection: NSWritingDirection, remainingRect: UnsafeMutablePointer<CGRect>) -> CGRect {
		var rect = proposedRect

		if let textController = textController, block = textController.canvasController.blockAt(presentationLocation: index) {
			let spacing = textController.theme.blockSpacing(block: block, horizontalSizeClass: textController.horizontalSizeClass)
			rect = spacing.applyPadding(rect)

			// Apply the top margin if it's not the second node
			let blocks = textController.canvasController.blocks
			if spacing.marginTop > 0 && blocks.count >= 2 && block.range.location > blocks[1].range.location {
				rect.origin.y += spacing.marginTop
			}
		}

		return super.lineFragmentRectForProposedRect(rect, atIndex: index, writingDirection: writingDirection, remainingRect: remainingRect)
	}
}
