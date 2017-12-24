//
//  UserInterfaceSizeClass.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/4/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit

	public enum UserInterfaceSizeClass: Int {
		case Unspecified
		case Compact
		case Regular
	}
#else
	import UIKit
	public typealias UserInterfaceSizeClass = UIUserInterfaceSizeClass
#endif
