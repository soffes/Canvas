public enum Position: String, CustomStringConvertible {
	case top
	case middle
	case bottom
	case single

	public var description: String {
		return rawValue
	}

	var successor: Position? {
		switch self {
		case .top, .middle:
			return .middle
		default:
			return nil
		}
	}

	public var isTop: Bool {
		switch self {
		case .top, .single:
			return true
		default:
			return false
		}
	}

	public var isMiddle: Bool {
		switch self {
		case .middle, .single:
			return true
		default:
			return false
		}
	}

	public var isBottom: Bool {
		switch self {
		case .bottom, .single:
			return true
		default:
			return false
		}
	}
}

public protocol Positionable: BlockNode {
	var position: Position { get set }
}
