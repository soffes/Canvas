import Foundation

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

			lines.append(render(spans: block.subnodes))
		}

		let output = lines.joined(separator: "\n")
		let bounds = NSRange(location: 0, length: (output as NSString).length)
		return InlineMarker.regularExpression.stringByReplacingMatches(in: output, options: [], range: bounds, withTemplate: "")
	}

    // MARK: - Private

	private func render(spans: [SpanNode]) -> String {
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
}
