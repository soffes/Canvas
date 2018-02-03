import XCTest
import CanvasNative

// Most of the parser is tested in the node tests.
final class ParserTests: XCTestCase {
	func testTrailingNewLine() {
		let blocks = Parser.parse("⧙doc-heading⧘Hello\n")

		XCTAssert(blocks[0] is Title)
		XCTAssertEqual(NSRange(location: 0, length: 18), blocks[0].range)

		XCTAssertEqual(2, blocks.count)
		XCTAssert(blocks[1] is Paragraph)
		XCTAssertEqual(NSRange(location: 19, length: 0), blocks[1].range)
	}
}
