//
//  Canvas+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 12/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import Static

extension Canvas {
	enum Kind {
		case document
		case blank

		var icon: UIImage! {
			switch self {
			case .document: return UIImage(named: "Document")
			case .blank: return UIImage(named: "Document-Blank")
			}
		}
	}

	var row: Row {
		return Row(
			text: displayTitle,
			detailText: summary,
			cellClass: CanvasCell.self,
			context: ["canvas": self]
		)
	}

	var kind: Kind {
		return isEmpty ? .blank : .document
	}

	var displayTitle: String {
		return title.isEmpty ? LocalizedString.untitled.string : title
	}
}
