import CanvasNative
import XCTest

final class DocumentControllerReliabilityTests: XCTestCase {

    // MARK: - Properties

	let delegate = TestDocumentControllerDelegate()

    // MARK: - Tests

	func testReliabilityInsertMidParagraph() {
		let controller = DocumentController(backingString: "⧙doc-heading⧘Title\nOne\nTwo", delegate: delegate)
		controller.replaceCharactersInRange(NSRange(location: 21, length: 0), withString: "1")
		XCTAssertEqual(delegate.presentationString, controller.document.presentationString)
		XCTAssertEqual(blockTypes(controller.document.backingString), delegate.blockTypes)

		controller.replaceCharactersInRange(NSRange(location: 22, length: 0), withString: "2")
		XCTAssertEqual(delegate.presentationString, controller.document.presentationString)
		XCTAssertEqual(blockTypes(controller.document.backingString), delegate.blockTypes)
	}
}
