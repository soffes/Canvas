#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import CanvasNative
import X

final class BlockquoteBorderView: ViewType, Annotation {

    // MARK: - Private

	var block: Annotatable

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

	let placement = AnnotationPlacement.expandedLeadingGutter

	var horizontalSizeClass: UserInterfaceSizeClass = .unspecified

    // MARK: - Initializers

	init?(block: Annotatable, theme: Theme) {
		guard let blockquote = block as? Blockquote else { return nil }
		self.block = blockquote
		self.theme = theme

		super.init(frame: .zero)

		#if !os(OSX)
			isUserInteractionEnabled = false
			contentMode = .redraw
			backgroundColor = theme.backgroundColor
		#endif
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - UIView

	override func draw(_ rect: CGRect) {
		#if os(OSX)
			guard let context = NSGraphicsContext.currentContext()?.CGContext else { return }

			theme.backgroundColor.setFill()
			CGContextFillRect(context, bounds)
		#else
			guard let context = UIGraphicsGetCurrentContext() else { return }
		#endif

		theme.blockquoteBorderColor.setFill()

		let rect = borderRect(for: bounds)
		context.fill(rect)
	}

    // MARK: - Private

	private func borderRect(for bounds: CGRect) -> CGRect {
		return CGRect(
			x: 1,
			y: 0,
			width: 4,
			height: bounds.height
		)
	}
}
