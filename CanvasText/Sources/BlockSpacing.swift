import CoreGraphics

public struct BlockSpacing {

	// MARK: - Properties

	public var paddingTop: CGFloat
	public var paddingRight: CGFloat
	public var paddingBottom: CGFloat
	public var paddingLeft: CGFloat

	public var marginTop: CGFloat
	public var marginBottom: CGFloat

	public static let zero = BlockSpacing()


	// MARK: - Initializers

	public init(paddingTop: CGFloat = 0, paddingRight: CGFloat = 0, paddingBottom: CGFloat = 0, paddingLeft: CGFloat = 0, marginTop: CGFloat = 0, marginBottom: CGFloat = 0) {
		self.paddingTop = paddingTop
		self.paddingRight = paddingRight
		self.paddingBottom = paddingBottom
		self.paddingLeft = paddingLeft

		self.marginTop = marginTop
		self.marginBottom = marginBottom
	}


	// MARK: - Utilities

	public func applyHorizontalPadding(_ rect: CGRect) -> CGRect {
		var output = rect

		// Padding left
		output.origin.x += paddingLeft
		output.size.width -= paddingLeft

		// Padding right
		output.size.width -= paddingRight

		return output
	}
}
