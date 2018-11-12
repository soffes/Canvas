import UIKit

final class SearchResultsViewController: DocumentsViewController {

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.contentInsetAdjustmentBehavior = .never
		tableView.contentInset = .zero

		let line = LineView()
		line.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(line)

		NSLayoutConstraint.activate([
			// Add search bar height :(
			line.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),

			line.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			line.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
	}
}
