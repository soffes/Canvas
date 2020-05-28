import XCTest
import CanvasNative

final class NodeTests: XCTestCase {
	func testOffset() {
		let before = Paragraph(string: "Hello", range: NSRange(location: 0, length: 5))!

		var after = before
		after.offset(8)

		XCTAssertEqual(NSRange(location: 8, length: 5), after.range)
	}
}
