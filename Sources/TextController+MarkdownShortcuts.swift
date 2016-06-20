//
//  TextController+MarkdownShortcuts.swift
//  CanvasText
//
//  Created by Sam Soffes on 4/15/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import CanvasNative

private typealias Match = (replacement: String, location: Int)

extension TextController {
	func processMarkdownShortcuts(presentationRange: NSRange) {
		let text = currentDocument.presentationString as NSString

		var searchRange = presentationRange
		if searchRange.max >= text.length {
			searchRange.length = text.length - searchRange.location
		}
		searchRange = text.lineRangeForRange(searchRange)

		// TODO: This fails if there is more than one line of markdown pasted since it's relative to the node before
		// we make any changes.
		text.enumerateSubstringsInRange(searchRange, options: .ByLines) { [weak self] string, range, _, _ in
			guard let string = string,
				document = self?.currentDocument,
				node = document.blockAt(presentationLocation: range.location)
			where (string as NSString).length > 0
			else { return }

			// FIXME: Update to support inline markers
			let backingRange = document.backingRanges(presentationRange: range)[0]
			var replacementRange = backingRange
			let replacement: String

			if let node = node as? UnorderedListItem, match = self?.prefixForUnorderedList(string, unorderedListItem: node) {
				replacement = match.replacement
				replacementRange = node.nativePrefixRange
				replacementRange.length += match.location
			} else if node is Paragraph, let match = self?.prefixForParagraph(string) {
				replacement = match.replacement
				replacementRange.length = match.location
			} else {
				return
			}

			// Replace
			self?.edit(backingRange: replacementRange, replacement: replacement)

			// Reset selection
			guard var selection = self?.presentationSelectedRange else { return }
			selection.location += 1
			selection.length = 0
			self?.setPresentationSelectedRange(selection, updateTextView: true)
		}
	}


	// MARK: - Private

	private func prefixForUnorderedList(string: String, unorderedListItem: UnorderedListItem? = nil) -> Match? {
		let scanner = NSScanner(string: string)
		scanner.charactersToBeSkipped = nil

		// Checklist item
		if let native = scanChecklist(scanner, unorderedListItem: unorderedListItem) {
			return (native, scanner.scanLocation)
		}

		return nil
	}

	private func prefixForParagraph(string: String) -> Match? {
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

	private func scanChecklist(scanner: NSScanner, unorderedListItem: UnorderedListItem? = nil) -> String? {
		let indentation: Indentation

		if let unorderedListItem = unorderedListItem {
			indentation = unorderedListItem.indentation
		} else {
			indentation = scanIndentation(scanner)

			guard scanner.scanString("-", intoString: nil) || scanner.scanString("*", intoString: nil) else { return nil }

			// Optional space
			scanner.scanString(" ", intoString: nil)
		}

		// Leading delimiter
		guard scanner.scanString("[", intoString: nil) else { return nil }

		// State
		let state: ChecklistItem.State
		if !scanner.scanString(" ", intoString: nil) {
			if scanner.scanString("x", intoString: nil) {
				state = .Checked
			} else {
				state = .Unchecked
			}
		} else {
			state = .Unchecked
		}

		// Trailing delimiter with required trailing space
		guard scanner.scanString("] ", intoString: nil) else { return nil }

		return ChecklistItem.nativeRepresentation(indentation: indentation, state: state)
	}

	private func scanUnorderedList(scanner: NSScanner) -> String? {
		let indentation = scanIndentation(scanner)
		let set = NSCharacterSet(charactersInString: "-*")
		guard scanner.scanCharactersFromSet(set, intoString: nil) && scanner.scanString(" ", intoString: nil) else {
			return nil
		}

		return UnorderedListItem.nativeRepresentation(indentation: indentation)
	}

	private func scanOrderedList(scanner: NSScanner) -> String? {
		let indentation = scanIndentation(scanner)
		guard scanner.scanInt(nil) && scanner.scanString(". ", intoString: nil) else { return nil }

		return OrderedListItem.nativeRepresentation(indentation: indentation)
	}

	private func scanIndentation(scanner: NSScanner) -> Indentation {
		var level: UInt = 0
		while scanner.scanString("    ", intoString: nil) || scanner.scanString("\t", intoString: nil) {
			level += 1
		}
		return Indentation(rawValue: level) ?? .Three
	}
}
