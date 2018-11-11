import CanvasCore
import Static
import UIKit

final class MyCanvasesViewController: CanvasesViewController {

	// MARK: - Properties

//	private let searchController: SearchController

	private let searchViewController: UISearchController

	var ready: (() -> Void)?

	var creating = false

	// MARK: - Initializers

	init() {
//		searchController = SearchController()

		let results = CanvasResultsViewController()
		searchViewController = UISearchController(searchResultsController: results)

		super.init()

		title = "Canvas"

		searchViewController.searchBar.placeholder = "Search"
//		searchViewController.searchResultsUpdater = searchController

//		searchController.callback = { [weak self] canvases in
//			guard let this = self, viewController = this.searchViewController.searchResultsController as? CanvasesViewController else { return }
//			viewController.dataSource.sections = [
//				Section(rows: canvases.map({ this.rowForCanvas($0) }))
//			]
//		}

		NotificationCenter.default.addObserver(self, selector: #selector(willCloseEditor),
											   name: EditorViewController.willCloseNotification, object: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - UIResponder

	override var keyCommands: [UIKeyCommand] {
		var commands = super.keyCommands

		commands += [
			UIKeyCommand(input: "/", modifierFlags: [], action: #selector(search), discoverabilityTitle: LocalizedString.searchCommand.string),
			UIKeyCommand(input: "n", modifierFlags: [.command], action: #selector(create), discoverabilityTitle: LocalizedString.newCanvasCommand.string)
		]

		return commands
	}

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Compose"), style: .plain,
															target: self, action: #selector(create))

		// Search setup
		definesPresentationContext = true
		extendedLayoutIncludesOpaqueBars = true
		searchViewController.hidesNavigationBarDuringPresentation = true

		// http://stackoverflow.com/a/33734661/118631
		searchViewController.loadViewIfNeeded()

		let header = SearchBarContainer(searchBar: searchViewController.searchBar)
		tableView.tableHeaderView = header

		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Compose"), style: .plain,
															target: self, action: #selector(create))
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Deselect search results *sigh*
		if let text = searchViewController.searchBar.text, !text.isEmpty,
			let viewController = searchViewController.searchResultsController as? CanvasesViewController,
			let indexPath = viewController.tableView.indexPathForSelectedRow
		{
			viewController.tableView.deselectRow(at: indexPath, animated: animated)
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		DispatchQueue.main.async { [weak self] in
			if let ready = self?.ready {
				ready()
				self?.ready = nil
			}
		}
	}

	// MARK: - CanvasesViewController

	override  func row(for canvas: Canvas) -> Row {
		var row = super.row(for: canvas)

		row.editActions = [
			Row.EditAction(title: LocalizedString.archiveButton.string, style: .destructive,
						   backgroundColor: Swatch.destructive, backgroundEffect: nil)
			{ [weak self] in
				self?.archive(canvas)
			}
		]

		return row
	}

	// MARK: - Actions

	@objc func create() {
		if creating {
			return
		}

		creating = true

		// TODO: Presist
		open(Canvas())
	}

	@objc func search() {
		searchViewController.searchBar.becomeFirstResponder()
	}

	private func archive(_ canvas: Canvas) {
		clearEditor(canvas: canvas)
		remove(canvas)

		// TODO: Persist
	}

	// MARK: - Private

	// Clear the detail view controller if it contains the given canvas
	private func clearEditor(canvas: Canvas) {
		guard let viewController = currentEditor(), let splitViewController = splitViewController,
			!splitViewController.isCollapsed else
		{
			return
		}

		if viewController.canvas == canvas {
			showDetailViewController(NavigationController(rootViewController: PlaceholderViewController()), sender: nil)
		}
	}

	private func remove(_ canvas: Canvas) {
		for (s, var section) in dataSource.sections.enumerated() {
			for (r, row) in section.rows.enumerated() {
				if let rowCanvas = row.context?["canvas"] as? Canvas, rowCanvas == canvas {
					section.rows.remove(at: r)

					if section.rows.isEmpty {
						dataSource.sections.remove(at: s)
					} else {
						dataSource.sections[s] = section
					}

					return
				}
			}
		}
	}

	private func updateCanvases(canvases: [Canvas]) {
		var groups = [Group: [Canvas]]()

		for canvas in canvases {
			for group in Group.all {
				if group.contains(canvas.updatedAt) {
					var list = groups[group] ?? [Canvas]()
					list.append(canvas)
					groups[group] = list
					break
				}
			}
		}

		var sections = [Section]()
		for group in Group.all {
			guard let canvases = groups[group] else { continue }

			let rows = canvases.map(self.row)

			let headerView = SectionHeaderView()
			headerView.textLabel.text = group.title

			sections.append(Section(header: .view(headerView), rows: rows))
		}

		dataSource.sections = sections
	}

	@objc private func willCloseEditor() {
		if let indexPath = tableView.indexPathForSelectedRow {
			tableView.deselectRow(at: indexPath, animated: false)
		}
	}
}
