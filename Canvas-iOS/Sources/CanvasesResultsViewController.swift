import UIKit
import CanvasCore

final class CanvasesResultsViewController: CanvasesViewController {

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let line = LineView()
		line.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(line)

		NSLayoutConstraint.activate([
			// Add search bar height :(
			line.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 44),

			line.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			line.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
	}
}
