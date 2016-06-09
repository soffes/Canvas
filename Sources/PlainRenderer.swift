//
//  PlainRenderer.swift
//  CanvasNative
//
//  Created by Sam Soffes on 6/9/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

public struct PlainRenderer: Renderer {

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
			guard let block = block as? NodeContainer else { continue }

			lines.append(renderSpans(block.subnodes))
		}

		return lines.joinWithSeparator("\n")
	}


	// MARK: - Private

	func renderSpans(spans: [SpanNode]) -> String {
		var output = ""

		for span in spans {
			// Add plain text
			if span is Text, let string = document.presentationString(backingRange: span.visibleRange) {
				output += string
			}

			// Recurse
			else if let span = span as? NodeContainer {
				output += renderSpans(span.subnodes)
			}
		}

		return output
	}
}
