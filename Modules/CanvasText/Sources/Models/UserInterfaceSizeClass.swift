#if os(OSX)
	import AppKit

	public enum UserInterfaceSizeClass: Int {
		case unspecified
		case compact
		case regular
	}
#else
	import UIKit
	public typealias UserInterfaceSizeClass = UIUserInterfaceSizeClass
#endif
