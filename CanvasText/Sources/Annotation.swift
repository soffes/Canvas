//
//  Annotation.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import CanvasNative
import X

public enum AnnotationPlacement {
	case firstLeadingGutter
	case expandedLeadingGutter
	case expandedBackground

	public var isExpanded: Bool {
		switch self {
		case .expandedLeadingGutter, .expandedBackground: return true
		default: return false
		}
	}
}

public protocol Annotation: class {
	var block: Annotatable { get set }
	var theme: Theme { get set }
	var view: ViewType { get }
	var placement: AnnotationPlacement { get }

	var horizontalSizeClass: UserInterfaceSizeClass { get set }

	init?(block: Annotatable, theme: Theme)
}


extension Annotation where Self: ViewType {
	public var view: ViewType {
		return self
	}

	public var placement: AnnotationPlacement {
		return .firstLeadingGutter
	}
}
