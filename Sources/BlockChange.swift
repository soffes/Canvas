//
//  BlockChange.swift
//  CanvasNative
//
//  Created by Sam Soffes on 4/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

enum BlockChange {
	case Insert(block: BlockNode, index: Int)
	case Remove(block: BlockNode, index: Int)
	case Replace(before: BlockNode, index: Int, after: BlockNode)
	case Update(before: BlockNode, index: Int, after: BlockNode)

	var index: Int {
		switch self {
		case .Insert(_, let index): return index
		case .Remove(_, let index): return index
		case .Replace(_, let index, _): return index
		case .Update(_, let index, _): return index
		}
	}
}
