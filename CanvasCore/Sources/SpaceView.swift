//
//  SpaceView.swift
//  CanvasCore
//
//  Created by Sam Soffes on 5/16/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

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

	private let contentSize: CGSize


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
		public override func intrinsicContentSize() -> CGSize {
			return contentSize
		}
	
		public override class func layerClass() -> AnyClass {
			return CATransformLayer.self
		}
	#endif
}


#if os(OSX)
	extension NSStackView {
		public func addSpace(length: CGFloat) {
			switch orientation {
			case .Horizontal: addArrangedSubview(SpaceView(width: length))
			case .Vertical: addArrangedSubview(SpaceView(height: length))
			}
		}
	}
#elseif os(iOS) || os(tvOS)
	extension UIStackView {
		public func addSpace(length: CGFloat) {
			switch axis {
			case .Horizontal: addArrangedSubview(SpaceView(width: length))
			case .Vertical: addArrangedSubview(SpaceView(height: length))
			}
		}
	}
#endif
