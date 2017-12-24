//
//  MarkdownRenderer.swift
//  CanvasNative
//
//  Created by Sam Soffes on 7/25/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

public struct MarkdownRenderer: Renderer {

	// MARK: - Properties

	public let document: Document


	// MARK: - Initializers

	public init(document: Document) {
		self.document = document
	}


	// MARK: - Renderer

	public func render() -> String {
		var lines = [String]()

		for block in document.blocks {
			lines.append(render(block: block))
		}

		let output = lines.joinWithSeparator("\n").stringByTrimmingCharactersInSet(.newlineCharacterSet())
		let bounds = NSRange(location: 0, length: (output as NSString).length)
		return InlineMarker.regularExpression.stringByReplacingMatchesInString(output, options: [], range: bounds, withTemplate: "")
	}


	// MARK: - Private

	private func render(block block: BlockNode) -> String {
		var output = ""

		// Blockquote
		if let block = block as? Blockquote {
			output = "> \(render(spans: block.subnodes))"
		}

		// Code block
		else if let block = block as? CodeBlock {
			// Opening
			if block.position.isTop {
				output = "```"

				if let language = block.language {
					output += " \(language)"
				}

				output += "\n"
			}

			// Content
			output += document.presentationString(backingRange: block.visibleRange)

			// Closing
			if block.position.isBottom {
				output += "\n```"
			}
		}

		// Heading
		else if let block = block as? Heading {
			output = "\(render(headingLevel: block.level)) \(render(spans: block.subnodes))"
		}

		// Horizontal rule
		else if block is HorizontalRule {
			output = "---"
		}

		// Image
		else if let block = block as? Image {
			let url = block.url?.absoluteString ?? ""
			output = "![](\(url))"
		}

		// Paragraph
		else if let block = block as? Paragraph {
			output = render(spans: block.subnodes)
		}

		// Title
		else if let block = block as? Title {
			output = "# \(render(spans: block.subnodes))"
		}

		// Listable
		else if let block = block as? Listable {
			output = render(indentation: block.indentation)

			// Checklist item
			if let block = block as? ChecklistItem {
				output += "- [\(block.state.string)] \(render(spans: block.subnodes))"
			}

			// Ordered list
			else if let block = block as? OrderedListItem {
				output += "\(block.number). \(render(spans: block.subnodes))"
			}

			// Unordered list
			else if let block = block as? UnorderedListItem {
				output += "- \(render(spans: block.subnodes))"
			}
		}

		// Add an extra new line after each item unless it's positionable and isn't the bottom
		let position = (block as? Positionable)?.position ?? .bottom
		if position.isBottom {
			output += "\n"
		}

		return output
	}

	private func render(spans spans: [SpanNode]) -> String {
		var output = ""

		for span in spans {
			// Add plain text
			if span is Text {
				output += document.presentationString(backingRange: span.visibleRange)
			}

			// Recurse
			else if let span = span as? NodeContainer {
				output += render(spans: span.subnodes)
			}
		}
		
		return output
	}

	private func render(indentation indentation: Indentation) -> String {
		guard !indentation.isMinimum else { return "" }

		var output = ""
		for _ in 0..<indentation.rawValue {
			output += "    "
		}
		return output
	}

	private func render(headingLevel level: Heading.Level) -> String {
		var output = ""
		for _ in 0..<level.rawValue {
			output += "#"
		}
		return output
	}
}
