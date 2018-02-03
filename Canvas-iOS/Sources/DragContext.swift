import UIKit
import CanvasNative

enum DragAction: String {
	case Increase
	case Decrease
}

struct DragContext {

	// MARK: - Properties

	static let threshold: CGFloat = 60

	let block: BlockNode
	let rect: CGRect
	let yContentOffset: CGFloat
	var dragAction: DragAction? = nil

	let contentView = UIView()

	private let backgroundView: UIView = {
		let view = DragBackgroundView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let leadingProgressView: DragProgressView
	let trailingProgressView: DragProgressView

	private let snapshotView: UIView
	private let snapshotLeadingConstraint: NSLayoutConstraint


	// MARK: - Initializers

	init(block: BlockNode, snapshotView: UIView, rect: CGRect, yContentOffset: CGFloat) {
		self.block = block
		self.snapshotView = snapshotView
		self.rect = rect
		self.yContentOffset = yContentOffset

		contentView.addSubview(backgroundView)

		let leading = DragProgressView(icon: DragContext.leadingIcon(block: block), isLeading: true)
		leading.translatesAutoresizingMaskIntoConstraints = false
		leadingProgressView = leading
		contentView.addSubview(leadingProgressView)

		let trailing = DragProgressView(icon: DragContext.trailingIcon(block: block), isLeading: false)
		trailing.translatesAutoresizingMaskIntoConstraints = false
		trailingProgressView = trailing
		contentView.addSubview(trailingProgressView)

		let snapshotSize = snapshotView.bounds.size
		snapshotView.isUserInteractionEnabled = false
		snapshotView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(snapshotView)

		snapshotLeadingConstraint = snapshotView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)

		NSLayoutConstraint.activate([
			backgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			backgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -4),
			backgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 4),

			leadingProgressView.leadingAnchor.constraint(lessThanOrEqualTo: contentView.leadingAnchor),
			leadingProgressView.trailingAnchor.constraint(equalTo: snapshotView.leadingAnchor),
			leadingProgressView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
			leadingProgressView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),

			trailingProgressView.leadingAnchor.constraint(equalTo: snapshotView.trailingAnchor),
			trailingProgressView.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor),
			trailingProgressView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
			trailingProgressView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),

			snapshotLeadingConstraint,
			snapshotView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -rect.minY + yContentOffset),
			snapshotView.widthAnchor.constraint(equalToConstant: snapshotSize.width),
			snapshotView.heightAnchor.constraint(equalToConstant: snapshotSize.height)
		])

		// Setup snapshot mask
		let mask = CAShapeLayer()
		mask.frame = snapshotView.layer.bounds
		mask.path = UIBezierPath(rect: rectForContentViewMask()).cgPath
		snapshotView.layer.mask = mask
	}


	// MARK: - Manipulation

	func translate(x: CGFloat) {
		snapshotLeadingConstraint.constant = x
		leadingProgressView.translate(x: x)
		trailingProgressView.translate(x: x)
		contentView.layoutIfNeeded()
	}

	func tearDown() {
		contentView.removeFromSuperview()
	}


	// MARK: - Private

	private func rectForContentViewMask() -> CGRect {
		var rect = self.rect
		rect.origin.x = 0
		rect.origin.y -= yContentOffset
		rect.size.width = snapshotView.bounds.size.width
		return rect
	}

	private static func leadingIcon(block: BlockNode) -> UIImage? {
		if block is Paragraph {
			return UIImage(named: "CheckList")
		}

		if block is ChecklistItem {
			return UIImage(named: "OrderedList")
		}

		if let block = block as? Listable {
			if block.indentation.isMaximum {
				return nil
			}

			return UIImage(named: "Indent")!
		}

		if let block = block as? Heading {
			if block.level == .three {
				return UIImage(named: "Paragraph")
			}

			switch block.level.successor {
			case .two: return UIImage(named: "Heading2")
			case .three: return UIImage(named: "Heading3")
			default: return nil
			}
		}

		return nil
	}

	private static func trailingIcon(block: BlockNode) -> UIImage? {
		if let block = block as? Listable {
			if block is ChecklistItem {
				return UIImage(named: "Paragraph")
			}

			if block.indentation.isMinimum {
				return UIImage(named: "CheckList")
			}

			return UIImage(named: "Outdent")
		}

		if block is Paragraph {
			return UIImage(named: "Heading3")
		}

		if let block = block as? Heading, block.level != .one {
			switch block.level.predecessor {
			case .two: return UIImage(named: "Heading2")
			case .three: return UIImage(named: "Heading3")
			default: return nil
			}
		}

		return nil
	}
}
