import CanvasCore
import UIKit

extension EditorViewController {
	@objc func closeNavigationControllerModal() {
		navigationController?.dismiss(animated: true)
	}

	@objc func close(_ sender: UIAlertAction? = nil) {
		NotificationCenter.default.post(name: EditorViewController.willCloseNotificationName, object: nil)
		dismissDetailViewController(self)
	}

	@objc func dismissKeyboard() {
		textView.resignFirstResponder()
	}

	@objc func check() {
		textController.toggleChecked()
	}

	@objc func indent() {
		textController.indent()
	}

	@objc func outdent() {
		textController.outdent()
	}

	@objc func bold() {
		textController.bold()
	}

	@objc func italic() {
		textController.italic()
	}

	@objc func inlineCode() {
		textController.inlineCode()
	}

	@objc func insertLineAfter() {
		textController.insertLineAfter()
	}

	@objc func insertLineBefore() {
		textController.insertLineBefore()
	}

	@objc func deleteLine() {
		textController.deleteLine()
	}

	@objc func swapLineUp() {
		textController.swapLineUp()
	}

	@objc func swapLineDown() {
		textController.swapLineDown()
	}
}
