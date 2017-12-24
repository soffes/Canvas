//
//  OrderedListItem+CanvasText.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/14/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasNative

extension OrderedListItem: Annotatable {
	public func annotation(theme theme: Theme) -> Annotation? {
		return NumberView(block: self, theme: theme)
	}
}
