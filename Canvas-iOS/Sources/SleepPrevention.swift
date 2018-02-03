import Foundation

enum SleepPrevention: String, CustomStringConvertible {
	case never
	case whilePluggedIn
	case always

	var description: String {
		switch self {
		case .never: return "System Default"
		case .whilePluggedIn: return "While Plugged In"
		case .always: return "Never Sleep"
		}
	}

	static let all: [SleepPrevention] = [.never, .whilePluggedIn, .always]

	static let defaultsKey = "PreventSleep"

	static var currentPreference: SleepPrevention {
		guard let string = UserDefaults.standard.string(forKey: defaultsKey) else { return .whilePluggedIn }
		return SleepPrevention(rawValue: string) ?? .whilePluggedIn
	}

	static func select(preference: SleepPrevention) {
		UserDefaults.standard.set(preference.rawValue, forKey: defaultsKey)
	}
}
