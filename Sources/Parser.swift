//
//  Parser.swift
//  CanvasNative
//
//  Created by Sam Soffes on 1/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

/// Given a string, parse into BlockNodes.
public struct Parser {

	// MARK: - Properties

	private static let blockParseOrder: [BlockNode.Type] = [
		Blockquote.self,
		ChecklistItem.self,
		CodeBlock.self,
		Title.self,
		Heading.self,
//		HorizontalRule.self,
		Image.self,
		OrderedListItem.self,
		UnorderedListItem.self,
		Paragraph.self
	]

	private static let spanParseOrder: [SpanNodeParseable.Type] = [
		CodeSpan.self,
		DoubleEmphasis.self,
		Emphasis.self,
		Strikethrough.self,
		Link.self
//		ReferenceLink.self
	]


	// MARK: - Parsing

	public static func parse(string: NSString, range: NSRange? = nil) -> [BlockNode] {
		return parse(string as String, range: range)
	}

	public static func parse(string: String, range: NSRange? = nil) -> [BlockNode] {
		var nodes = [BlockNode]()

		let text = string as NSString
		let bounds = NSRange(location: 0, length: text.length)
		var parseRange = range ?? bounds

		// If the range is zero, use the bounds.
		if parseRange.equals(.zero) {
			parseRange = bounds
		}

		// Enumerate the string blocks of the `backingText`.
		var max = 0
		text.enumerateSubstringsInRange(parseRange, options: [.ByLines]) { substring, range, enclosingRange, _ in
			// Ensure we have a substring to work with
			guard let substring = substring else { return }

			max = range.max

			for type in self.blockParseOrder {
				guard var node = type.init(string: substring, range: range) else { continue }

				// Parse inline markers
				if var container = node as? InlineMarkerContainer {
					container.inlineMarkerPairs = self.parseInlineMarkers(string: string, container: container)
					node = container as BlockNode
				}

				// Parse inline
				if var container = node as? NodeContainer {
					container.subnodes = self.parseInline(string: string, container: container)

					if let container = container as? BlockNode {
						node = container
					}
				}

				nodes.append(node)

				return
			}

			// Future: Add support for unknown node types #8
		}

		// Support trailing new line
		if max < text.length {
			nodes.append(Paragraph(range: NSRange(location: max + 1, length: 0)))
		}

		nodes = calculatePositions(nodes)

		return nodes
	}


	// MARK: - Private

	private static func parseInline(string string: String, container: NodeContainer) -> [SpanNode] {
		var subnodes = [SpanNode]()

		for type in spanParseOrder {
			let regularExpression = type.regularExpression
			let matches = regularExpression.matchesInString(string, options: [], range: container.textRange)
			if matches.isEmpty {
				continue
			}

			for match in matches {
				// Skip if there is already a sibling for this range
				var skip = false
				for sibling in subnodes {
					if sibling.range.intersection(match.rangeAtIndex(0)) != nil {
						skip = true
						break
					}
				}

				guard !skip, let node = type.init(match: match) else { continue }

				// Recurse
				if var node = node as? SpanNodeContainer {
					node.subnodes = parseInline(string: string, container: node)
					subnodes.append(node)
				} else {
					subnodes.append(node)
				}
			}
		}

		// Add text nodes
		var output = [SpanNode]()

		var last = container.textRange.location

		for node in subnodes.sort({ $0.range.location < $1.range.location }) {
			if node.range.location != last {
				output.append(Text(range: NSRange(location: last, length: node.range.location - last)))
			}
			output.append(node)
			last = node.range.max
		}

		if last < container.textRange.max {
			output.append(Text(range: NSRange(location: last, length: container.textRange.max - last)))
		}

		return output
	}

	private static func parseInlineMarkers(string string: String, container: InlineMarkerContainer) -> [InlineMarkerPair] {
		let matches = InlineMarker.regularExpression.matchesInString(string, options: [], range: container.visibleRange)
		if matches.isEmpty {
			return []
		}

		let text = (string as NSString)

		let markers: [InlineMarker] = matches.flatMap { result in
			guard result.numberOfRanges == 5 else { return nil }
			let id = text.substringWithRange(result.rangeAtIndex(4))
			let position: InlineMarker.Position = result.rangeAtIndex(2).length == 0 ? .opening : .closing
			return InlineMarker(range: result.rangeAtIndex(0), position: position, id: id)
		}

		return InlineMarkerPair.pairs(markers: markers)
	}

	private static func isContinuous(lhs: Positionable?, _ rhs: Positionable?) -> Bool {
		guard let lhs = lhs, rhs = rhs where lhs.dynamicType == rhs.dynamicType else { return false }

		if let lhsCode = lhs as? CodeBlock, rhsCode = rhs as? CodeBlock where lhsCode.language != rhsCode.language {
			return false
		}

		return true
	}

	private static func calculatePositions(blocks: [BlockNode]) -> [BlockNode] {
		var blocks = blocks
		let count = blocks.count

		var orderedIndentations = [Indentation: UInt]()
		var lastIndentation: Indentation?

		var codeLineNumber: UInt = 0

		for (i, block) in blocks.enumerate() {
			guard var currentBlock = block as? Positionable else {
				codeLineNumber = 0
				orderedIndentations.removeAll()
				continue
			}

			// Update ordered list items number
			if var item = currentBlock as? OrderedListItem {
				if let last = lastIndentation where last > item.indentation {
					orderedIndentations.removeValueForKey(last)
				}
				
				let value = (orderedIndentations[item.indentation] ?? 0) + 1
				orderedIndentations[item.indentation] = value
				item.number = value
				currentBlock = item as Positionable
				lastIndentation = item.indentation
			} else {
				orderedIndentations.removeAll()
			}

			// Code block line numbers
			if var code = currentBlock as? CodeBlock {
				codeLineNumber += 1
				code.lineNumber = codeLineNumber
				currentBlock = code as Positionable
			} else {
				codeLineNumber = 0
			}

			// Look behind and look ahead
			let previousBlock = i > 0 ? blocks[i - 1] as? Positionable : nil
			let nextBlock = i < count - 1 ? blocks[i + 1] as? Positionable : nil

			var position: Position

			// Starting position
			if isContinuous(previousBlock, currentBlock), let nextPosition = previousBlock?.position.successor {
				position = nextPosition
			} else {
				position = .top
			}

			// Check for ending
			if !isContinuous(currentBlock, nextBlock) {
				if position == .top {
					position = .single
				} else {
					position = .bottom
				}

				codeLineNumber = 0
			}

			// Update block
			currentBlock.position = position
			blocks[i] = currentBlock
		}

		return blocks
	}
}
