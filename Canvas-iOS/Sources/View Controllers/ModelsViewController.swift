import CanvasCore
import Static
import UIKit

// TODO: Localize this class
class ModelsViewController: TableViewController {

    // MARK: - UIResponder

	override var canBecomeFirstResponder: Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand] {
		var commands = super.keyCommands ?? []

		if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
			let previousTitle = (navigationController.viewControllers[navigationController.viewControllers.count - 2]).title
			let backTitle = previousTitle.flatMap { "Back to \($0)" } ?? "Back"

			commands += [
				UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(goBack), discoverabilityTitle: backTitle),
				UIKeyCommand(input: "w", modifierFlags: [.command], action: #selector(goBack))
			]
		}

		return commands
	}

    // MARK: - Actions

	@objc private func goBack() {
		navigationController?.popViewController(animated: true)
	}
}
