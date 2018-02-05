struct SelectionController {
	static func adjust(selection: NSRange, replacementRange: NSRange, replacementLength: Int) -> NSRange {
		// No change
		if replacementRange.length == 0 && replacementLength == 0 {
			return selection
		}

		var output = selection

		// Inserting
		if replacementLength > 0 {

			if selection.location == replacementRange.location {
				return NSRange(location: selection.location + replacementLength, length: 0)
			}

			// Shift selection
			if replacementRange.max < output.location {
				output.location += replacementLength - replacementRange.length
			}

			// Extend selection
			else {
				output.length += NSIntersectionRange(selection, NSRange(location: replacementRange.location, length: replacementLength - replacementRange.length)).length
			}
		}

		// Deleting
		else {
			// Shift selection
			if replacementRange.location < selection.location {
				output.location -= replacementRange.length
			}

			// Subtract selection
			output.length -= NSIntersectionRange(selection, replacementRange).length
		}

		return output
	}
}
