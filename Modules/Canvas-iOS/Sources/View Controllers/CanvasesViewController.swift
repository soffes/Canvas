import CanvasCore
import CanvasNative
import Static
import UIKit

class CanvasesViewController: ModelsViewController {

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

		title = "Canvas"

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Compose"), style: .plain,
															target: self, action: #selector(create))

		tableView.rowHeight = 72
	}

	// MARK: - ModelsViewController

	func open(_ canvas: Canvas) {
		if let editor = currentEditor(), editor.canvas == canvas {
			return
		}

		let viewController = EditorViewController(canvas: canvas)
		showDetailViewController(NavigationController(rootViewController: viewController), sender: self)
	}

	// MARK: - Actions

	@objc private func create(_ sender: Any?) {
		open(Canvas())
	}

	// MARK: - Utilities

	func currentEditor() -> EditorViewController? {
		guard let splitViewController = splitViewController, splitViewController.viewControllers.count == 2 else {
			return nil
		}

		let top = (splitViewController.viewControllers.last as? UINavigationController)?.topViewController
		return top as? EditorViewController
	}

	func row(for canvas: Canvas) -> Row {
		var row = canvas.row
		row.selection = { [weak self] in self?.open(canvas) }
		return row
	}
}
