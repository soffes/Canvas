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
		let text = documentController.document.presentationString as NSString

		if NSMaxRange(presentationRange) > text.length {
			return
		}

		let searchRange = NSUnionRange(presentationRange, text.lineRangeForRange(presentationRange))

		text.enumerateSubstringsInRange(searchRange, options: .ByLines) { [weak self] string, range, enclosingRange, _ in
			guard let string = string,
				document = self?.documentController.document,
				node = document.blockAt(presentationLocation: range.location)
			where (string as NSString).length > 0
			else { return }

			let backingRange = document.backingRange(presentationRange: range)
			var replacementRange = backingRange
			var replacement: String

			if let node = node as? UnorderedListItem, match = self?.prefixForUnorderedList(string) {
				replacement = match.0
				replacementRange = node.nativePrefixRange
				replacementRange.length += match.1
			} else if node is Paragraph, let match = self?.prefixForParagraph(string) {
				replacement = match.0
				replacementRange.length = match.1
			} else {
				return
			}

			// Replace
			self?.edit(backingRange: replacementRange, replacement: replacement)

			// Update selection
			guard let updated = self?.documentController.document else { return }
			var selection = updated.presentationRange(backingRange: replacementRange)
			selection.location = NSMaxRange(selection) - 1
			selection.length = 0
			self?.presentationSelectedRange = selection
		}
	}


	// MARK: - Private

	private func prefixForUnorderedList(string: String) -> (String, Int)? {
		let scanner = NSScanner(string: string)
		scanner.charactersToBeSkipped = nil

		// Checklist item
		if let native = scanChecklist(scanner, requireUnorderedListPrefix: false) {
			return (native, scanner.scanLocation)
		}

		return nil
	}

	private func prefixForParagraph(string: String) -> (String, Int)? {
		let scanner = NSScanner(string: string)
		scanner.charactersToBeSkipped = nil

		// Blockquote
		if let native = scanBlockquote(scanner) {
			return (native, scanner.scanLocation)
		}

		// Checklist item
		scanner.scanLocation = 0
		if let native = scanChecklist(scanner) {
			return (native, scanner.scanLocation)
		}

		// Unordered list
		scanner.scanLocation = 0
		if let native = scanUnorderedList(scanner) {
			return (native, scanner.scanLocation)
		}

		// Ordered list
		scanner.scanLocation = 0
		if let native = scanOrderedList(scanner) {
			return (native, scanner.scanLocation)
		}


		return nil
	}

	private func scanBlockquote(scanner: NSScanner) -> String? {
		guard scanner.scanString("> ", intoString: nil) else { return nil }
		return Blockquote.nativeRepresentation()
	}

	// TODO: Support scanning in an unordered list as well as a paragraph8
	private func scanChecklist(scanner: NSScanner, requireUnorderedListPrefix: Bool = true) -> String? {
		// List prefix
		if requireUnorderedListPrefix {
			guard scanner.scanString("-", intoString: nil) || scanner.scanString("*", intoString: nil) else { return nil }

			// Optional space
			scanner.scanString(" ", intoString: nil)
		}

		// Leading delimiter
		guard scanner.scanString("[", intoString: nil) else { return nil }

		// Completion
		let completion: ChecklistItem.Completion
		if !scanner.scanString(" ", intoString: nil) {
			if scanner.scanString("x", intoString: nil) {
				completion = .Complete
			} else {
				completion = .Incomplete
			}
		} else {
			completion = .Incomplete
		}

		// Trailing delimiter with required trailing space
		guard scanner.scanString("] ", intoString: nil) else { return nil }

		// TODO: Handle indentation
		return ChecklistItem.nativeRepresentation(indentation: .Zero, completion: completion)
	}

	private func scanUnorderedList(scanner: NSScanner) -> String? {
		let set = NSCharacterSet(charactersInString: "-*")
		guard scanner.scanCharactersFromSet(set, intoString: nil) && scanner.scanString(" ", intoString: nil) else {
			return nil
		}

		// TODO: Handle indentation
		return UnorderedListItem.nativeRepresentation()
	}

	private func scanOrderedList(scanner: NSScanner) -> String? {
		guard scanner.scanInt(nil) && scanner.scanString(". ", intoString: nil) else { return nil }

		// TODO: Handle indentation
		return OrderedListItem.nativeRepresentation()
	}
}
