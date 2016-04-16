//
//  TextController+MarkdownShortcuts.swift
//  CanvasText
//
//  Created by Sam Soffes on 4/15/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import CanvasNative

extension TextController {
	func processMarkdownShortcuts(presentationRange: NSRange) {
		let document = documentController.document
		let text = document.presentationString as NSString

		if NSMaxRange(presentationRange) > text.length {
			return
		}

		let searchRange = NSUnionRange(presentationRange, text.lineRangeForRange(presentationRange))

		text.enumerateSubstringsInRange(searchRange, options: .ByLines) { [weak self] string, range, enclosingRange, _ in
			guard let string = string,
				node = document.blockAt(presentationLocation: range.location)
			where (string as NSString).length > 0
			else { return }

			let backingRange = document.backingRange(presentationRange: range)
			var replacementRange = backingRange
			let replacement: String

//			if let node = node as? UnorderedListItem {
//				replacementRange = NSUnionRange(node.nativePrefixRange, backingRange)
//
//				// Checklist item
//				if string.hasPrefix("[] ") || string.hasPrefix("[ ] ") {
//					replacement = ChecklistItem.nativeRepresentation(indentation: node.indentation, completion: .Incomplete)
//				}
//
//					// Completed checklist item
//				else if string.hasPrefix("[x] ") {
//					replacement = ChecklistItem.nativeRepresentation(indentation: node.indentation, completion: .Complete)
//				} else {
//					return
//				}
//			} else

			if node is Paragraph, let (prefix, replacedLength) = self?.prefixForParagraph(string) {
				replacementRange.length = replacedLength
				replacement = prefix
			} else {
				return
			}

			self?.edit(backingRange: replacementRange, replacement: replacement)
		}
	}


	// MARK: - Private

	private func prefixForParagraph(string: String) -> (String, Int)? {
		let scanner = NSScanner(string: string)
		scanner.charactersToBeSkipped = nil

		// Blockquote
		if scanner.scanString("> ", intoString: nil) {
			return (Blockquote.nativeRepresentation(), scanner.scanLocation)
		}

		// TODO: Process indentation

		// Incomplete checklist item
		//		scanner.scanLocation = 0
		//    if string.hasPrefix("-[] ") || string.hasPrefix("- [] ") || string.hasPrefix("- [ ] ") || string.hasPrefix("*[] ") || string.hasPrefix("* [] ") || string.hasPrefix("* [ ] ") {
		//      return ChecklistItem.nativeRepresentation(indentation: .Zero, completion: .Incomplete)
		//    }

		// Complete checklist item
		//		scanner.scanLocation = 0
		//    if string.hasPrefix("-[x] ") || string.hasPrefix("- [x] ") || string.hasPrefix("*[x] ") || string.hasPrefix("* [x] ") {
		//      return ChecklistItem.nativeRepresentation(indentation: .Zero, completion: .Complete)
		//    }

		// Unordered list
		scanner.scanLocation = 0
		if scanner.scanString("* ", intoString: nil) || scanner.scanString("- ", intoString: nil) {
			return (UnorderedListItem.nativeRepresentation(), scanner.scanLocation)
		}

		// Ordered list
		scanner.scanLocation = 0
		if scanner.scanInt(nil) && scanner.scanString(". ", intoString: nil) {
			return (OrderedListItem.nativeRepresentation(), scanner.scanLocation)
		}

		return nil
	}
}
