import Foundation
import Diff

typealias BlockChange = (range: CountableRange<Int>, replacement: [BlockNode])
typealias StringChange = (range: NSRange, replacement: NSString)


struct DocumentChange {

	// MARK: - Properties

	let before: Document
	let after: Document

	let blockChange: BlockChange?
	let backingStringChange: StringChange
	let presentationStringChange: StringChange?


	// MARK: - Initializers

	init(before: Document, after: Document, blockChange: BlockChange?, backingStringChange: StringChange, presentationStringChange: StringChange?) {
		self.before = before
		self.after = after
		self.blockChange = blockChange
		self.backingStringChange = backingStringChange
		self.presentationStringChange = presentationStringChange
	}
}


extension Document {
	func replaceCharactersInRange(_ range: NSRange, withString string: String) -> DocumentChange {
		let before = self

		// Calculate new backing string
		let text = NSMutableString(string: before.backingString)
		text.replaceCharacters(in: range, with: string)
		let backingStringChange = StringChange(range: range, replacement: string as NSString)

		// Create new document
		let after = Document(backingString: text as String)

		// Calculate block changes
		let blockChange = diff(before.blocks, after.blocks) { beforeBlock, afterBlock in
			// If they are different types or have different lengths, they are definitely not equal.
			if type(of: beforeBlock) != type(of: afterBlock) || beforeBlock.range.length != afterBlock.range.length {
				return false
			}

			// Check positionable
			if let before = beforeBlock as? Positionable, let after = afterBlock as? Positionable, before.position != after.position {
				return false
			}

			// Check code block
			if let before = beforeBlock as? CodeBlock, let after = afterBlock as? CodeBlock, before.lineNumber != after.lineNumber {
				return false
			}

			// Check ordered list
			if let before = beforeBlock as? OrderedListItem, let after = afterBlock as? OrderedListItem, before.number != after.number {
				return false
			}

			// Compare their native representations
			return (before.backingString as NSString).substring(with: beforeBlock.range) == (after.backingString as NSString).substring(with: afterBlock.range)
		}

		// Calculate presentation change
		let presentationStringChange = diff(before.presentationString as NSString, after.presentationString as NSString)

		return DocumentChange(
			before: before,
			after: after,
			blockChange: blockChange,
			backingStringChange: backingStringChange,
			presentationStringChange: presentationStringChange
		)
	}
}
