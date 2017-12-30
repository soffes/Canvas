//
//  ChecklistItem+CanvasText.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasNative

extension ChecklistItem: Annotatable {
	public func annotation(theme: Theme) -> Annotation? {
		return CheckboxView(block: self, theme: theme)
	}
}
