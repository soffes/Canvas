//
//  CodeBlock.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct CodeBlock: NativePrefixable, Positionable, Annotatable, ReturnCompletable {

	// MARK: - Properties

	public var range: NSRange
	public var enclosingRange: NSRange
	public var nativePrefixRange: NSRange
	public var displayRange: NSRange
	public var position: Position = .Single


	// MARK: - Initializers

	public init?(string: String, range: NSRange, enclosingRange: NSRange) {
		guard let (nativePrefixRange, displayRange) = parseBlockNode(
			string: string,
			range: range,
			delimiter: "code"
		) else { return nil }

		self.range = range
		self.enclosingRange = enclosingRange
		self.nativePrefixRange = nativePrefixRange
		self.displayRange = displayRange
	}


	// MARK: - Node

	public mutating func offset(delta: Int) {
		range.location += delta
		enclosingRange.location += delta
		nativePrefixRange.location += delta
		displayRange.location += delta
	}


	// MARK: - Native

	public static func nativeRepresentation() -> String {
		return "\(leadingNativePrefix)code\(trailingNativePrefix)"
	}
}
