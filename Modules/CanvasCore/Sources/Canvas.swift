import Foundation

public struct Canvas {

    // MARK: - Properties

	public let id: String
	public let title: String?
	public let summary: String?
	public let createdAt: Date
	public let updatedAt: Date
	public let archivedAt: Date?

	public var isEmpty: Bool {
		return summary?.isEmpty ?? true
	}

	public init(id: String = UUID().uuidString, title: String? = nil, summary: String? = nil, createdAt: Date? = nil,
				updatedAt: Date? = nil, archivedAt: Date? = nil)
	{
		self.id = id
		self.title = title
		self.summary = summary

		let now = Date()
		self.createdAt = createdAt ?? now
		self.updatedAt = updatedAt ?? now
		self.archivedAt = archivedAt
	}
}

extension Canvas: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	public static func == (lhs: Canvas, rhs: Canvas) -> Bool {
		return lhs.id == rhs.id
	}
}
