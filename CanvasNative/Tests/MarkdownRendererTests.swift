import XCTest
import CanvasNative

final class MarkdownRendererTests: XCTestCase {
	func testRenderer() {
		let document = Document(backingString: "⧙doc-heading⧘Output\nHello\nThere\n⧙unordered-list-0⧘- This\n⧙unordered-list-0⧘- is\n⧙unordered-list-0⧘- a\n⧙unordered-list-0⧘- list\nMore after that.")
		let renderer = MarkdownRenderer(document: document)
		XCTAssertEqual("# Output\n\nHello\n\nThere\n\n- This\n- is\n- a\n- list\n\nMore after that.", renderer.render())
	}

	func testOrderedLists() {
		let document = Document(backingString: "⧙doc-heading⧘Ordered\n⧙ordered-list-0⧘1. One\n⧙ordered-list-1⧘1. Two\n⧙ordered-list-0⧘1. Three")
		let renderer = MarkdownRenderer(document: document)
		XCTAssertEqual("# Ordered\n\n1. One\n    1. Two\n2. Three", renderer.render())
	}
}
