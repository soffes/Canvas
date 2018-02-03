import XCTest
import CanvasNative

final class DocumentControllerInsertTests: XCTestCase {

    // MARK: - Properties

	let delegate = TestDocumentControllerDelegate()

    // MARK: - Tests

	func testLoading() {
		let controller = DocumentController(delegate: delegate)

		let will = expectation(description: "controllerWillUpdateNodes")
		delegate.willUpdate = { will.fulfill() }

		let insertTitle = expectation(description: "controller:didInsertBlock:atIndex: Title")
		let insertParagraph = expectation(description: "controller:didInsertBlock:atIndex: Paragraph")
		delegate.didInsert = { node, index in
			if node is Title {
				XCTAssertEqual(0, index)
				insertTitle.fulfill()
			} else if node is Paragraph {
				XCTAssertEqual(1, index)
				insertParagraph.fulfill()
			} else {
				XCTFail("Unexpected insert.")
			}
		}

		delegate.didRemove = { _, _ in XCTFail("Shouldn't remove.") }

		let did = expectation(description: "controllerDidUpdateNodes")
		delegate.didUpdate = { did.fulfill() }

		controller.replaceCharactersInRange(NSRange(location: 0, length: 0), withString: "⧙doc-heading⧘Title\nParagraph")
		waitForExpectations(timeout: 0.1, handler: nil)

		XCTAssertEqual(delegate.presentationString, controller.document.presentationString)
		XCTAssertEqual(blockTypes(controller.document.backingString), delegate.blockTypes)
	}
}
