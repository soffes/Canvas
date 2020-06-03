import CanvasCore
import UIKit

final class AlertController: UIAlertController {

    // MARK: - Properties

	/// Used when return is pressed while the controller is showing
	var primaryAction: (() -> Void)?

    // MARK: - UIResponder

	override var canBecomeFirstResponder: Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand]? {
		return (super.keyCommands ?? []) + [
			UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(cancel)),
			UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(selectFirstAction))
		]
	}

    // MARK: - UIViewController

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		adjust([view])
	}

    // MARK: - Actions

	@objc func cancel() {
		dismiss(animated: true, completion: nil)
	}

	@objc func selectFirstAction() {
		dismiss(animated: true) {
			self.primaryAction?()
		}
	}

    // MARK: - Private

	private func adjust(_ subviews: [UIView]) {
		for subview in subviews {
			if let label = subview as? UILabel {
				adjust(label)
			} else if subview.bounds.height > 0 && subview.bounds.height <= 1 {
				subview.backgroundColor = Swatch.border
			}

			adjust(subview.subviews)
		}
	}

	private func adjust(_ label: UILabel) {
		guard let font = label.font else {
			return
		}

		for action in actions {
			if label.text == title {
				label.attributedText = NSAttributedString(string: label.text ?? "", attributes: [
					.font: font,
					.foregroundColor: Swatch.darkGray
				])
				return
			}

			if label.text == action.title {
				switch action.style {
				case .default, .cancel:
					label.attributedText = NSAttributedString(string: label.text ?? "", attributes: [
						.font: font,
						.foregroundColor: Swatch.brand
					])
				case .destructive:
					label.attributedText = NSAttributedString(string: label.text ?? "", attributes: [
						.font: font,
						.foregroundColor: Swatch.destructive
					])
				@unknown default:
					return
				}
			}
		}
	}
}
