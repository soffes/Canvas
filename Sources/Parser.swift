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
		Link.self,
//		ReferenceLink.self,
		DoubleEmphasis.self,
		Emphasis.self
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
		text.enumerateSubstringsInRange(parseRange, options: [.ByLines]) { substring, range, enclosingRange, _ in
			// Ensure we have a substring to work with
			guard let substring = substring else { return }

			for type in self.blockParseOrder {
				guard var node = type.init(string: substring, range: range, enclosingRange: enclosingRange) else { continue }

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

		nodes = calculatePositions(nodes)

		return nodes
	}


	// MARK: - Private

	private static func parseInline(string string: String, container: NodeContainer) -> [SpanNode] {
		var subnodes = [SpanNode]()

		for type in spanParseOrder {
			let regularExpression = type.regularExpression
			let matches = regularExpression.matchesInString(string, options: [], range: container.textRange)
			if matches.count == 0 {
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

	private static func calculatePositions(nodes: [BlockNode]) -> [BlockNode] {
		var nodes = nodes

		// Add position information
		var positionableType: Positionable.Type?
		var	positionables = [Positionable]()

		func applyPositions(index: Int) {
			let count = positionables.count
			for (i, p) in positionables.enumerate() {
				var positionable = p

				if count == 1 {
					positionable.position = .Single
				} else if i == 0 {
					positionable.position = .Top
				} else if i == count - 1 {
					positionable.position = .Bottom
				} else {
					positionable.position = .Middle
				}

				guard let node = positionable as? BlockNode else { continue }
				nodes[index - count + i] = node
			}

			positionableType = nil
			positionables.removeAll()
		}

		for (i, node) in nodes.enumerate() {
			guard let positionable = node as? Positionable else {
				applyPositions(i)
				continue
			}

			if positionableType != positionable.dynamicType {
				applyPositions(i)
				positionableType = positionable.dynamicType
			}

			positionables.append(positionable)
		}

		applyPositions(nodes.count)

		return nodes
	}
}
