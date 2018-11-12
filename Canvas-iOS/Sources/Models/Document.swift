import CanvasCore
import CanvasNative
import UIKit

final class Document: UIDocument {

	// MARK: - Types

	enum Error: Swift.Error {
		case invalidCanvas
		case unsupportedVersion
	}

	// MARK: - Properties

	let version = "0.0.1"
	private(set) var id: String
	private(set) var title: String?
	private(set) var summary: String?
	private(set) var createdAt: Date
	private (set) var updatedAt: Date

	var isEmpty: Bool {
		return summary?.isEmpty ?? true
	}

	private(set) var canvas = Canvas()
	var document = CanvasNative.Document() {
		didSet {
			title = document.title

			// TODO: Calculate summary
			summary = nil
		}
	}

	// MARK: - Initializers

	@available(*, unavailable)
	init() {
		fatalError("Must call init(fileURL:) instead.")
	}

	init(id: String = UUID().uuidString, saveCompletion: ((Bool) -> Void)? = nil) throws {
		self.id = id
		createdAt = Date()
		updatedAt = createdAt

		let documentsURL = try FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		let url = documentsURL.appendingPathComponent(id)
			.appendingPathExtension("canvas")

		super.init(fileURL: url)

		save(to: url, for: .forCreating, completionHandler: saveCompletion)
	}

	// MARK: - UIDocument

	override func contents(forType typeName: String) throws -> Any {
		let dateFormatter = ISO8601DateFormatter()
		var json: [String: Any] = [
			"version": version,
			"id": id,
			"createdAt": dateFormatter.string(from: createdAt),
			"updatedAt": dateFormatter.string(from: updatedAt),
			"document": document.backingString
		]

		if let title = title {
			json["title"] = title
		}

		if let summary = summary {
			json["summary"] = summary
		}

		return try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
	}

	override func load(fromContents contents: Any, ofType typeName: String?) throws {
		let dateFormatter = ISO8601DateFormatter()
		guard let data = contents as? Data,
			let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
			let version = json["version"] as? String, let id = json["id"] as? String,
			let createdAtString = json["createdAt"] as? String,
			let createdAt = dateFormatter.date(from: createdAtString),
			let updatedAtString = json["updatedAt"] as? String,
			let updatedAt = dateFormatter.date(from: updatedAtString), let document = json["document"] as? String else
		{
			throw Error.invalidCanvas
		}

		if version != self.version {
			throw Error.unsupportedVersion
		}

		self.id = id
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.document = CanvasNative.Document(backingString: document)
	}
}
