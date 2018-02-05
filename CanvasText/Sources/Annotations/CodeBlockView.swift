#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import CanvasNative
import X

final class CodeBlockView: ViewType, Annotation {

    // MARK: - Properties

	static let lineNumberWidth: CGFloat = 40

	var block: Annotatable

	var theme: Theme {
		didSet {
			backgroundColor = theme.codeBlockBackgroundColor
			tintColor = theme.tintColor
			setNeedsDisplay()
		}
	}

	var horizontalSizeClass: UserInterfaceSizeClass = .unspecified

	let placement = AnnotationPlacement.expandedBackground

	private let textLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .right
		return label
	}()

    // MARK: - Initializers

	init?(block: Annotatable, theme: Theme) {
		guard let codeBlock = block as? CodeBlock else {
            return nil
        }
		self.block = codeBlock
		self.theme = theme

		super.init(frame: .zero)

		isUserInteractionEnabled = false
		contentMode = .redraw
		backgroundColor = theme.backgroundColor

		textLabel.font = TextStyle.body.monoSpaceFont()
		textLabel.text = codeBlock.lineNumber.description
		textLabel.textColor = theme.codeBlockLineNumberColor
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - UIView

	override func draw(_ rect: CGRect) {
		guard let codeBlock = block as? CodeBlock, let context = UIGraphicsGetCurrentContext() else {
            return
        }

		let path: CGPath?

		switch codeBlock.position {
		case .single:
			path = UIBezierPath(roundedRect: bounds, cornerRadius: 4).cgPath
		case .top:
			path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 4, height: 4)).cgPath
		case .bottom:
			path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 4, height: 4)).cgPath
		default:
			path = nil
		}

		if let path = path {
			context.addPath(path)
			context.clip()
		}

		context.setFillColor(theme.codeBlockBackgroundColor.cgColor)
		context.fill(bounds)

		// Line numbers background
		if traitCollection.horizontalSizeClass == .regular {
			context.setFillColor(theme.codeBlockLineNumberBackgroundColor.cgColor)
			context.fill(CGRect(x: 0, y: 0, width: type(of: self).lineNumberWidth, height: bounds.height))
		}
	}

	override func traitCollectionDidChange(_ previousTraitOrganization: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitOrganization)

		guard let codeBlock = block as? CodeBlock else {
            return
        }

		if traitCollection.horizontalSizeClass != .regular {
			textLabel.removeFromSuperview()
			return
		}

		if textLabel.superview == nil {
			addSubview(textLabel)

			// TODO: This is terrible
			let top: CGFloat = codeBlock.position.isTop ? 10 : 1

			NSLayoutConstraint.activate([
				textLabel.trailingAnchor.constraint(equalTo: leadingAnchor, constant: type(of: self).lineNumberWidth - 6),
				textLabel.topAnchor.constraint(equalTo: topAnchor, constant: top)
			])
		}

		setNeedsDisplay()
	}
}
