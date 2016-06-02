//
//  Positionable.swift
//  CanvasNative
//
//  Created by Sam Soffes on 2/3/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

public enum Position: Equatable {
	case Top
	case Middle(UInt)
	case Bottom(UInt)
	case Single

	var successor: Position? {
		switch self {
		case .Top: return .Middle(2)
		case .Middle(let number): return .Middle(number + 1)
		default: return nil
		}
	}

	var number: UInt {
		switch self {
		case .Middle(let number): return number
		case .Bottom(let number): return number
		default: return 1
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
		case .Middle(_), .Single: return true
		default: return false
		}
	}

	public var isBottom: Bool {
		switch self {
		case .Bottom(_), .Single: return true
		default: return false
		}
	}
}


public func ==(lhs: Position, rhs: Position) -> Bool {
	switch lhs {
	case .Top:
		switch rhs {
		case .Top: return true
		default: return false
		}
	case .Middle(let lhsNumber):
		switch rhs {
		case .Middle(let rhsNumber): return lhsNumber == rhsNumber
		default: return false
		}
	case .Bottom(let lhsNumber):
		switch rhs {
		case .Bottom(let rhsNumber): return lhsNumber == rhsNumber
		default: return false
		}
	case .Single:
		switch rhs {
		case .Single: return true
		default: return false
		}
	}
}


public protocol Positionable: BlockNode {
	var position: Position { get set }
}
