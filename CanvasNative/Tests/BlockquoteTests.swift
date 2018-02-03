import XCTest
import CanvasNative

final class BlockquoteTest: XCTestCase {
	func testBlockquote() {
		let node = Blockquote(string: "⧙blockquote⧘> Hello", range: NSRange(location: 0, length: 19))!
		XCTAssertEqual(NSRange(location: 0, length: 14), node.nativePrefixRange)
		XCTAssertEqual(NSRange(location: 14, length: 5), node.visibleRange)
	}

	func testInline() {
		let node = Parser.parse("⧙blockquote⧘> Hello **world**").first! as! Blockquote
		XCTAssertEqual(NSRange(location: 14, length: 15), node.textRange)
		XCTAssert(node.subnodes[0] is Text)
		XCTAssert(node.subnodes[1] is DoubleEmphasis)
	}
}
