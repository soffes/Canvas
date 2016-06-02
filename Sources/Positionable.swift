//
//  Positionable.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/3/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

public enum Position: String, CustomStringConvertible {
	case Top
	case Middle
	case Bottom
	case Single

	public var description: String {
		return rawValue
	}

	var successor: Position? {
		switch self {
		case .Top, .Middle: return .Middle
		default: return nil
		}
	}

	public var isTop: Bool {
		switch self {
		case .Top, .Single: return true
		default: return false
		}
	}

	public var isMiddle: Bool {
		switch self {
		case .Middle, .Single: return true
		default: return false
		}
	}

	public var isBottom: Bool {
		switch self {
		case .Bottom, .Single: return true
		default: return false
		}
	}
}


public protocol Positionable: BlockNode {
	var position: Position { get set }
}
