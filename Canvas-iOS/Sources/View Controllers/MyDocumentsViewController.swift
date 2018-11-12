import CanvasCore
import Static
import UIKit

final class MyDocumentsViewController: DocumentsViewController {

	// MARK: - Properties

	private let searchController = SearchController()

	private let searchViewController = UISearchController(searchResultsController: SearchResultsViewController())

	var ready: (() -> Void)?

	var creating = false

	// MARK: - Initializers

	init() {
		super.init()

		title = "Canvas"

		searchViewController.searchBar.placeholder = "Search"
		searchViewController.searchResultsUpdater = searchController

		searchController.callback = { [weak self] documents in
			guard let self = self,
				let viewController = self.searchViewController.searchResultsController as? DocumentsViewController else
			{
				return
			}

			viewController.dataSource.sections = [
				Section(rows: documents.map(self.row))
			]
		}

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
//			UIKeyCommand(input: "/", modifierFlags: [], action: #selector(search), discoverabilityTitle: LocalizedString.searchCommand.string),
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

//		let header = SearchBarContainer(searchBar: searchViewController.searchBar)
//		tableView.tableHeaderView = header

		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Compose"), style: .plain,
															target: self, action: #selector(create))
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Deselect search results *sigh*
		if let text = searchViewController.searchBar.text, !text.isEmpty,
			let viewController = searchViewController.searchResultsController as? DocumentsViewController,
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

	override func row(for document: Document) -> Row {
		var row = super.row(for: document)

		row.editActions = [
			Row.EditAction(title: "Delete", style: .destructive,
						   backgroundColor: Swatch.destructive, backgroundEffect: nil)
			{ [weak self] in
				self?.deleteDocument(document)
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

		let document: Document
		do {
			document = try Document()
		} catch {
			// TODO: Real error handling
			fatalError("Failed to create document")
		}

		// TODO: Update list
		open(document)
	}

	@objc func search() {
		searchViewController.searchBar.becomeFirstResponder()
	}

	private func deleteDocument(_ document: Document) {
		// TODO: Add confirmation

		clearEditor(document: document)
		remove(document)

		// TODO: Persist
	}

	// MARK: - Private

	// Clear the detail view controller if it contains the given canvas
	private func clearEditor(document: Document) {
		guard let viewController = currentEditor(), let splitViewController = splitViewController,
			!splitViewController.isCollapsed else
		{
			return
		}

		if viewController.document == document {
			showDetailViewController(NavigationController(rootViewController: PlaceholderViewController()), sender: nil)
		}
	}

	private func remove(_ document: Document) {
		for (s, var section) in dataSource.sections.enumerated() {
			for (r, row) in section.rows.enumerated() {
				if let rowCanvas = row.context?["canvas"] as? Canvas, rowCanvas == document.canvas {
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

	private func updateDocuments(_ documents: [Document]) {
		var groups = [Group: [Document]]()

		for document in documents {
			for group in Group.all {
				if group.contains(document.canvas.updatedAt) {
					var list = groups[group] ?? [Document]()
					list.append(document)
					groups[group] = list
					break
				}
			}
		}

		var sections = [Section]()
		for group in Group.all {
			guard let documents = groups[group] else { continue }

			let rows = documents.map(self.row)

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
