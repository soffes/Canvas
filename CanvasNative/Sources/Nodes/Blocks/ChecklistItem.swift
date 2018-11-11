import Foundation

public struct ChecklistItem: Listable, Equatable {

	// MARK: - Types

	public enum State: String {
		case unchecked = " "
		case checked = "x"

		public var string: String {
			return rawValue
		}

		public var opposite: State {
			switch self {
			case .unchecked:
				return .checked
			case .checked:
				return .unchecked
			}
		}
	}

	// MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange
	public var visibleRange: NSRange
	public var indentationRange: NSRange
	public var indentation: Indentation
	public var stateRange: NSRange
	public var state: State
	public var position: Position = .single

	public var textRange: NSRange {
		return visibleRange
	}

	public var subnodes = [SpanNode]()
	public var inlineMarkerPairs = [InlineMarkerPair]()

	public var dictionary: [String: Any] {
		return [
			"type": "checklist-item",
			"range": range.dictionary,
			"nativePrefixRange": nativePrefixRange.dictionary,
			"visibleRange": visibleRange.dictionary,
			"indentationRange": indentationRange.dictionary,
			"indentation": indentation.rawValue,
			"stateRange": stateRange.dictionary,
			"state": state.rawValue,
			"position": position.description,
			"subnodes": subnodes.map { $0.dictionary },
			"inlineMarkerPairs": inlineMarkerPairs.map { $0.dictionary }
		]
	}

	// MARK: - Initializers

	public init?(string: String, range: NSRange) {
		let scanner = Scanner(string: string)
		scanner.charactersToBeSkipped = nil

		// Delimiter
		if !scanner.scanString("\(leadingNativePrefix)checklist-", into: nil) {
			return nil
		}

		var indent = -1
		let indentationLocation = scanner.scanLocation
		if !scanner.scanInt(&indent) {
			return nil
		}

		let indentationRange = NSRange(location: range.location + indentationLocation,
									   length: scanner.scanLocation - indentationLocation)
		guard indent != -1, let indentation = Indentation(rawValue: UInt(indent)) else {
			return nil
		}

		self.indentationRange = indentationRange
		self.indentation = indentation

		if !scanner.scanString(trailingNativePrefix, into: nil) {
			return nil
		}

		let nativePrefixRange = NSRange(location: range.location, length: scanner.scanLocation)

		// Prefix
		let startPrefix = scanner.scanLocation
		if !scanner.scanString("- [", into: nil) {
			return nil
		}

		let set = CharacterSet(charactersIn: "x ")
		var stateString: NSString? = ""
		let stateRange = NSRange(location: range.location + scanner.scanLocation, length: 1)
		if !scanner.scanCharacters(from: set, into: &stateString) {
			return nil
		}

		if let stateString = stateString as String?, let state = State(rawValue: stateString) {
			self.state = state
		} else {
			return nil
		}

		if !scanner.scanString("] ", into: nil) {
			return nil
		}

		let prefixRange = NSRange(location: range.location + startPrefix, length: scanner.scanLocation - startPrefix)
		self.nativePrefixRange = nativePrefixRange.union(prefixRange)

		// Content
		self.stateRange = stateRange
		visibleRange = NSRange(
			location: range.location + scanner.scanLocation,
			length: range.length - scanner.scanLocation
		)

		self.range = range
	}

	// MARK: - Node

	public mutating func offset(_ delta: Int) {
		range.location += delta
		nativePrefixRange.location += delta
		visibleRange.location += delta
		indentationRange.location += delta
		stateRange.location += delta

		subnodes = subnodes.map {
			var node = $0
			node.offset(delta)
			return node
		}

		inlineMarkerPairs = inlineMarkerPairs.map {
			var pair = $0
			pair.offset(delta)
			return pair
		}
	}

	// MARK: - Native

	public static func nativeRepresentation(indentation: Indentation = .zero, state: State = .unchecked) -> String {
		return "\(leadingNativePrefix)checklist-\(indentation.string)\(trailingNativePrefix)- [\(state.string)] "
	}
}

public func == (lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
	return NSEqualRanges(lhs.range, rhs.range) &&
		NSEqualRanges(lhs.nativePrefixRange, rhs.nativePrefixRange) &&
		NSEqualRanges(lhs.visibleRange, rhs.visibleRange) &&
		NSEqualRanges(lhs.indentationRange, rhs.indentationRange) &&
		lhs.indentation == rhs.indentation &&
		NSEqualRanges(lhs.stateRange, rhs.stateRange) &&
		lhs.state == rhs.state &&
		lhs.position == rhs.position
}
