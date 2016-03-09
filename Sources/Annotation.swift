//
//  Annotation.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasNative

public enum AnnotationStyle {
	case LeadingGutter
	case Background
}

public protocol Annotation: class {
	var block: Annotatable { get }
	var theme: Theme { get set }
	var view: View { get }
	var style: AnnotationStyle { get }
	var horizontalSizeClass: UserInterfaceSizeClass { get set }

	init?(block: Annotatable, theme: Theme)
}


extension Annotation where Self: View {
	public var view: View {
		return self
	}

	public var style: AnnotationStyle {
		return .LeadingGutter
	}
}
