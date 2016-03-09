//
//  CodeBlock+CanvasText.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasNative

extension CodeBlock: Annotatable {
	public func annotation(theme theme: Theme) -> Annotation? {
		return CodeBlockView(block: self, theme: theme)
	}
}
