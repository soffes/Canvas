//
//  Annotatable.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasNative

public protocol Annotatable: BlockNode {
	func annotation(theme theme: Theme) -> Annotation?
}
