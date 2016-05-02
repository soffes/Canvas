//
//  Attachable.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/25/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

public protocol Attachable: NativePrefixable {}

extension Attachable {
	public var visibleRange: NSRange {
		return NSRange(location: nativePrefixRange.max, length: 1)
	}
	
	public func contentInString(string: String) -> String {
		return String(Character(UnicodeScalar(NSAttachmentCharacter)))
	}
}
