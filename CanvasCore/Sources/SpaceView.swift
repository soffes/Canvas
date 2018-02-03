import X

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

/// Space view intented to be used with auto layout.
/// Similar to UIStackView, setting a background color is not supported.
public final class SpaceView: View {

    // MARK: - Properties

	fileprivate let contentSize: CGSize

    // MARK: - Initializers

	public init(size: CGSize) {
		contentSize = size
		super.init(frame: .zero)
	}

	public convenience init(height: CGFloat) {
		#if os(OSX)
			self.init(size: CGSize(width: NSViewNoIntrinsicMetric, height: height))
		#else
			self.init(size: CGSize(width: UIViewNoIntrinsicMetric, height: height))
		#endif
	}

	public convenience init(width: CGFloat) {
		#if os(OSX)
			self.init(size: CGSize(width: width, height: NSViewNoIntrinsicMetric))
		#else
			self.init(size: CGSize(width: width, height: UIViewNoIntrinsicMetric))
		#endif
	}

	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - UIView

	#if os(OSX)
		public override var intrinsicContentSize: NSSize {
			return contentSize
		}
	#else
		public override var intrinsicContentSize: CGSize {
			return contentSize
		}

		public override class var layerClass: AnyClass {
			return CATransformLayer.self
		}
	#endif
}


#if os(OSX)
	extension NSStackView {
		public func addSpace(length: CGFloat) {
			switch orientation {
			case .Horizontal: addArrangedSubview(SpaceView(width: length))
			case .vertical: addArrangedSubview(SpaceView(height: length))
			}
		}
	}
#elseif os(iOS) || os(tvOS)
	extension UIStackView {
		public func addSpace(_ length: CGFloat) {
			switch axis {
			case .horizontal: addArrangedSubview(SpaceView(width: length))
			case .vertical: addArrangedSubview(SpaceView(height: length))
			}
		}
	}
#endif
