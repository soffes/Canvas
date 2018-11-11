import Foundation

public struct LinkTitle {

	// MARK: - Properties

	public var leadingDelimiterRange: NSRange
	public var textRange: NSRange
	public var trailingDelimiterRange: NSRange

	public var range: NSRange {
		return leadingDelimiterRange.union(textRange).union(trailingDelimiterRange)
	}

	public var dictionary: [String: Any] {
		return [
			"leadingTitleDelimiterRange": leadingDelimiterRange,
			"titleRange": textRange,
			"trailingTitleDelimiterRange": trailingDelimiterRange
		]
	}

	// MARK: - Initializers

	public init(leadingDelimiterRange: NSRange, textRange: NSRange, trailingDelimiterRange: NSRange) {
		self.leadingDelimiterRange = leadingDelimiterRange
		self.textRange = textRange
		self.trailingDelimiterRange = trailingDelimiterRange
	}

	init?(match: NSTextCheckingResult) {
		leadingDelimiterRange = match.range(at: 6)
		textRange = match.range(at: 7)
		trailingDelimiterRange = match.range(at: 8)

		guard leadingDelimiterRange.location != NSNotFound &&
			textRange.location != NSNotFound &&
			trailingDelimiterRange.location != NSNotFound else
		{
	    	return nil
    	}
	}

	// MARK: - Mutating

	public mutating func offset(_ delta: Int) {
		leadingDelimiterRange.location += delta
		textRange.location += delta
		trailingDelimiterRange.location += delta
	}
}

public struct Link: SpanNode, Foldable, NodeContainer {

	// MARK: - Properties

	public var range: NSRange
	public var leadingTextDelimiterRange: NSRange
	public var textRange: NSRange
	public var trailingTextDelimiterRange: NSRange
	public var leadingUrlDelimiterRange: NSRange
	public var urlRange: NSRange
	public var title: LinkTitle?
	public var trailingURLDelimiterRange: NSRange

	public var visibleRange: NSRange {
		return range
	}

	public var foldableRanges: [NSRange] {
		let before = leadingTextDelimiterRange
		var after = trailingTextDelimiterRange.union(leadingUrlDelimiterRange).union(urlRange)

		if let title = title {
			after = after.union(title.range)
		}

		after = after.union(trailingURLDelimiterRange)

		return [before, after]
	}

	public var dictionary: [String: Any] {
		var dictionary: [String: Any] = [
			"type": "link",
			"range": range.dictionary,
			"visibleRange": visibleRange.dictionary,
			"leadingTextDelimiterRange": leadingTextDelimiterRange.dictionary,
			"textRange": textRange.dictionary,
			"trailingTextDelimiterRange": trailingTextDelimiterRange.dictionary,
			"leadingUrlDelimiterRange": leadingUrlDelimiterRange.dictionary,
			"urlRange": urlRange.dictionary,
			"trailingURLDelimiterRange": trailingURLDelimiterRange.dictionary,
			"subnodes": subnodes.map { $0.dictionary }
		]

		if let title = title {
			for (key, value) in title.dictionary {
				dictionary[key] = value
			}
		}

		return dictionary
	}

	public var subnodes = [SpanNode]()

	// MARK: - Initializers

	public init(range: NSRange, leadingTextDelimiterRange: NSRange, textRange: NSRange,
				trailingTextDelimiterRange: NSRange, leadingUrlDelimiterRange: NSRange, urlRange: NSRange,
				title: LinkTitle? = nil, trailingURLDelimiterRange: NSRange, subnodes: [SpanNode])
	{
		self.range = range
		self.leadingTextDelimiterRange = leadingTextDelimiterRange
		self.textRange = textRange
		self.trailingTextDelimiterRange = trailingTextDelimiterRange
		self.leadingUrlDelimiterRange = leadingUrlDelimiterRange
		self.urlRange = urlRange
		self.title = title
		self.trailingURLDelimiterRange = trailingURLDelimiterRange
		self.subnodes = subnodes
	}

	// MARK: - Node

	public mutating func offset(_ delta: Int) {
		range.location += delta
		leadingTextDelimiterRange.location += delta
		textRange.location += delta
		trailingTextDelimiterRange.location += delta
		leadingUrlDelimiterRange.location += delta
		urlRange.location += delta
		trailingURLDelimiterRange.location += delta

		title?.offset(delta)

		subnodes = subnodes.map {
			var node = $0
			node.offset(delta)
			return node
		}
	}

	// MARK: - URL

	public func URL(backingString: String) -> Foundation.URL? {
		var string = (backingString as NSString).substring(with: urlRange)

		if !string.contains("://") {
			string = "http://\(string)"
		}

		return Foundation.URL(string: string)
	}
}

extension Link: SpanNodeParseable {
	static let regularExpression = (try? NSRegularExpression(pattern: "(\\[)((?:(?:\\\\.)|[^\\[\\]])+)(\\])(\\()([^\\(\\)\\s]+(?:\\(\\S*?\\))??[^\\(\\)\\s]*?)(?:\\s+(['‘’\"“”])(.*?)(\\6))?(\\))", options: []))!

	public init?(match: NSTextCheckingResult) {
		if match.numberOfRanges != 10 {
			return nil
		}

		range = match.range(at: 0)
		leadingTextDelimiterRange = match.range(at: 1)
		textRange = match.range(at: 2)
		trailingTextDelimiterRange = match.range(at: 3)
		leadingUrlDelimiterRange = match.range(at: 4)
		urlRange = match.range(at: 5)
		title = LinkTitle(match: match)
		trailingURLDelimiterRange = match.range(at: 9)
	}
}

extension Link: SpanNodeContainer {}
