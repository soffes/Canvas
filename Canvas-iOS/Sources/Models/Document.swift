import CanvasCore
import CanvasNative
import MobileCoreServices
import UIKit

final class Document: UIDocument {

	// MARK: - Types

	enum Error: Swift.Error {
		case invalidCanvas
		case unsupportedVersion
		case unableToSave
	}

	// MARK: - Properties

	let version = "0.0.1"
	private(set) var id = ""
	private(set) var title: String?
	private(set) var summary: String?

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

	static let uti: String = {
		let utiDecs = Bundle.main.object(forInfoDictionaryKey: kUTExportedTypeDeclarationsKey as String) as? [[String: Any]]
		return (utiDecs?.first?[kUTTypeIdentifierKey as String] as? String)!
	}()

	// MARK: - Initializers

	@available(*, unavailable)
	init() {
		fatalError("Must call init(fileURL:) instead.")
	}

	convenience init(id: String = UUID().uuidString, saveCompletion: ((Bool) -> Void)? = nil) throws {
		let documentsURL = try FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		let url = documentsURL.appendingPathComponent(id)
			.appendingPathExtension("canvas")

		self.init(fileURL: url)

		self.id = id

		save(to: url, for: .forCreating, completionHandler: saveCompletion)
	}

	override init(fileURL url: URL) {
		super.init(fileURL: url)
	}

	// MARK: - UIDocument

	override func contents(forType typeName: String) throws -> Any {
		var json: [String: Any] = [
			"version": version,
			"id": id,
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
		guard let data = contents as? Data,
			let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
			let version = json["version"] as? String, let id = json["id"] as? String,
			let document = json["document"] as? String else
		{
			throw Error.invalidCanvas
		}

		if version != self.version {
			throw Error.unsupportedVersion
		}

		self.id = id
		self.document = CanvasNative.Document(backingString: document)
	}

	override func fileNameExtension(forType typeName: String?, saveOperation: UIDocument.SaveOperation) -> String {
		if typeName == type(of: self).uti {
			return "canvas"
		}

		return super.fileNameExtension(forType: typeName, saveOperation: saveOperation)
	}

	override var localizedName: String {
		return title ?? super.localizedName
	}
}
