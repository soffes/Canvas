#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import CanvasNative
import X

final class BulletView: ViewType, Annotation {

    // MARK: - Private

	var block: Annotatable {
		didSet {
			guard let old = oldValue as? UnorderedListItem, let new = block as? UnorderedListItem else { return }

			if old.indentation.isFilled != new.indentation.isFilled {
				#if os(OSX)
					needsDisplay = true
				#else
					setNeedsDisplay()
				#endif
			}
		}
	}

	var theme: Theme {
		didSet {
			#if os(OSX)
				needsDisplay = true
			#else
				backgroundColor = theme.backgroundColor
				setNeedsDisplay()
			#endif
		}
	}

	var horizontalSizeClass: UserInterfaceSizeClass = .unspecified

    // MARK: - Initializers

	init?(block: Annotatable, theme: Theme) {
		guard let unorderedListItem = block as? UnorderedListItem else { return nil }
		self.block = unorderedListItem
		self.theme = theme

		super.init(frame: .zero)

		#if !os(OSX)
			isUserInteractionEnabled = false
			contentMode = .redraw
			backgroundColor = theme.backgroundColor
		#endif
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - UIView

	override func draw(_ rect: CGRect) {
		guard let unorderedListItem = block as? UnorderedListItem else { return }

		#if os(OSX)
			guard let context = NSGraphicsContext.currentContext()?.CGContext else { return }

			theme.backgroundColor.setFill()
			CGContextFillRect(context, bounds)
		#else
			guard let context = UIGraphicsGetCurrentContext() else { return }
		#endif

		theme.bulletColor.set()

		let rect = bulletRect(for: bounds)

		if unorderedListItem.indentation.isFilled {
			context.fillEllipse(in: rect)
		} else {
			context.setLineWidth(2)
			context.strokeEllipse(in: rect.insetBy(dx: 1, dy: 1))
		}
	}

    // MARK: - Private

	private func bulletRect(for bounds: CGRect) -> CGRect {
		let dimension: CGFloat = 8

		return CGRect(
			x: bounds.width - dimension - 8,
			y: round((bounds.height - dimension) / 2) - 1,
			width: dimension,
			height: dimension
		)
	}
}
