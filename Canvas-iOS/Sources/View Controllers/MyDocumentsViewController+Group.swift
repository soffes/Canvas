import CanvasCore
import Foundation

extension MyDocumentsViewController {
	enum Group: String {
		case today
		case recent
		case week
		case month
		case forever

		var title: String {
			switch self {
			case .today:
				return LocalizedString.todayTitle.string
			case .recent:
				return LocalizedString.recentTitle.string
			case .week:
				return LocalizedString.thisWeekTitle.string
			case .month:
				return LocalizedString.thisMonthTitle.string
			case .forever:
				return LocalizedString.olderTitle.string
			}
		}

		static let all: [Group] = [.today, .recent, .week, .month, .forever]

		func contains(_ date: Date) -> Bool {
			let calendar = Calendar.current

			let now = Date()

			switch self {
			case .today:
				return calendar.isDateInToday(date)
			case .recent:
				guard let end = calendar.date(byAdding: .day, value: -3, to: now) else {
					return false
				}
				return calendar.compare(date, to: end, toGranularity: .day) == .orderedDescending
			case .week:
				guard let end = calendar.date(byAdding: .day, value: -7, to: now) else {
					return false
				}
				return calendar.compare(date, to: end, toGranularity: .day) == .orderedDescending
			case .month:
				guard let end = calendar.date(byAdding: .month, value: -1, to: now) else {
					return false
				}
				return calendar.compare(date, to: end, toGranularity: .day) == .orderedDescending
			case .forever:
				return true
			}
		}
	}
}
