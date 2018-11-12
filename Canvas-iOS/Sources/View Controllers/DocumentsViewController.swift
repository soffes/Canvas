import CanvasCore
import CanvasNative
import Static
import UIKit

class DocumentsViewController: ModelsViewController {

	// MARK: - Initializers

	override init(style: UITableView.Style = .plain) {
		super.init(style: style)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.rowHeight = 72
	}

	// MARK: - ModelsViewController

	func open(_ document: Document) {
		if let editor = currentEditor(), editor.document == document {
			return
		}

		document.open { [weak self] opened in
			if !opened {
				fatalError("failed to open: \(document)")
			}

			let viewController = EditorViewController(document: document)
			self?.showDetailViewController(NavigationController(rootViewController: viewController), sender: self)
		}
	}

	// MARK: - Utilities

	func currentEditor() -> EditorViewController? {
		guard let splitViewController = splitViewController, splitViewController.viewControllers.count == 2 else {
			return nil
		}

		let top = (splitViewController.viewControllers.last as? UINavigationController)?.topViewController
		return top as? EditorViewController
	}

	func row(for document: Document) -> Row {
		var row = document.canvas.row
		row.selection = { [weak self] in self?.open(document) }
		return row
	}
}
