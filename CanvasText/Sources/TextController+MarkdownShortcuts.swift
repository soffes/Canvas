import CanvasNative
import Foundation

private typealias Match = (replacement: String, location: Int)

extension TextController {
	func processMarkdownShortcuts(_ presentationRange: NSRange) {
		let text = currentDocument.presentationString as NSString

		var searchRange = presentationRange
		if searchRange.max >= text.length {
			searchRange.length = text.length - searchRange.location
		}
		searchRange = text.lineRange(for: searchRange)

		// TODO: This fails if there is more than one line of markdown pasted since it's relative to the node before
		// we make any changes.
		text.enumerateSubstrings(in: searchRange, options: .byLines) { [weak self] string, range, _, _ in
			guard let string = string,
				let document = self?.currentDocument,
				let node = document.blockAt(presentationLocation: range.location), (string as NSString).length > 0 else
			{
				return
			}

			// FIXME: Update to support inline markers
			let backingRange = document.backingRanges(presentationRange: range)[0]
			var replacementRange = backingRange
			let replacement: String

			if let node = node as? UnorderedListItem, let match = self?.prefixForUnorderedList(string, unorderedListItem: node) {
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
			guard var selection = self?.presentationSelectedRange else {
	    	return
    	}
			selection.length = 0

			DispatchQueue.main.async {
				self?.set(presentationSelectedRange: selection, updateTextView: true)
			}
		}
	}

	// MARK: - Private

	private func prefixForUnorderedList(_ string: String, unorderedListItem: UnorderedListItem? = nil) -> Match? {
		let scanner = Scanner(string: string)
		scanner.charactersToBeSkipped = nil

		// Checklist item
		if let native = scanChecklist(scanner, unorderedListItem: unorderedListItem) {
			return (native, scanner.scanLocation)
		}

		return nil
	}

	private func prefixForParagraph(_ string: String) -> Match? {
		let scanner = Scanner(string: string)
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

	private func scanBlockquote(_ scanner: Scanner) -> String? {
		guard scanner.scanString("> ", into: nil) else {
	    	return nil
    	}
		return Blockquote.nativeRepresentation()
	}

	private func scanChecklist(_ scanner: Scanner, unorderedListItem: UnorderedListItem? = nil) -> String? {
		let indentation: Indentation

		if let unorderedListItem = unorderedListItem {
			indentation = unorderedListItem.indentation
		} else {
			indentation = scanIndentation(scanner)

			guard scanner.scanString("-", into: nil) || scanner.scanString("*", into: nil) else {
	    	return nil
    	}

			// Optional space
			scanner.scanString(" ", into: nil)
		}

		// Leading delimiter
		guard scanner.scanString("[", into: nil) else {
	    	return nil
    	}

		// State
		let state: ChecklistItem.State
		if !scanner.scanString(" ", into: nil) {
			if scanner.scanString("x", into: nil) {
				state = .checked
			} else {
				state = .unchecked
			}
		} else {
			state = .unchecked
		}

		// Trailing delimiter with required trailing space
		guard scanner.scanString("] ", into: nil) else {
	    	return nil
    	}

		return ChecklistItem.nativeRepresentation(indentation: indentation, state: state)
	}

	private func scanUnorderedList(_ scanner: Scanner) -> String? {
		let indentation = scanIndentation(scanner)
		let set = CharacterSet(charactersIn: "-*")
		guard scanner.scanCharacters(from: set, into: nil) && scanner.scanString(" ", into: nil) else {
			return nil
		}

		return UnorderedListItem.nativeRepresentation(indentation: indentation)
	}

	private func scanOrderedList(_ scanner: Scanner) -> String? {
		let indentation = scanIndentation(scanner)
		guard scanner.scanInt32(nil) && scanner.scanString(". ", into: nil) else {
	    	return nil
    	}

		return OrderedListItem.nativeRepresentation(indentation: indentation)
	}

	private func scanIndentation(_ scanner: Scanner) -> Indentation {
		var level: UInt = 0
		while scanner.scanString("    ", into: nil) || scanner.scanString("\t", into: nil) {
			level += 1
		}
		return Indentation(rawValue: level) ?? .three
	}
}
