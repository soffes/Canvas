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

		if let textController = textController, block = textController.currentDocument.blockAt(presentationLocation: index) {
			let blockSpacing = textController.blockSpacing(block: block)
			rect = blockSpacing.applyPadding(rect)
		}

		return super.lineFragmentRectForProposedRect(rect, atIndex: index, writingDirection: writingDirection, remainingRect: remainingRect)
	}
}
