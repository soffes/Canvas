import CanvasCore
import Static
import UIKit

class TableViewController: UIViewController {

    // MARK: - Properties

	let tableView: UITableView

	/// Table view data source.
	var dataSource = DataSource() {
		willSet {
			dataSource.tableView = nil
		}

		didSet {
			dataSource.tableView = tableView
		}
	}
    // MARK: - Initializers

	init(style: UITableView.Style) {
		tableView = TableView(frame: .zero, style: style)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.separatorColor = Swatch.border

		dataSource.tableView = tableView

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(tableView)

		NSLayoutConstraint.activate([
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])

		dataSource.automaticallyDeselectRows = false
		dataSource.tableView = tableView
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		tableView.indexPathsForSelectedRows?.forEach { indexPath in
			tableView.deselectRow(at: indexPath, animated: false)
		}
	}
}
