import Foundation
import CoreGraphics

public struct Image: Attachable, Equatable {

	// MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange

	public var identifier: String
	public var url: URL?
	public var size: CGSize?

	public var dictionary: [String: Any] {
		var dictionary: [String: Any] = [
			"type": "ordered-list",
			"range": range.dictionary,
			"nativePrefixRange": nativePrefixRange.dictionary,
			"identifier": identifier
		]

		if let url = url {
			dictionary["url"] = url.absoluteString
		}

		if let size = size {
			dictionary["size"] = size.dictionary
		}

		return dictionary
	}

	public var hiddenRanges: [NSRange] {
		return [nativePrefixRange]
	}


	// MARK: - Initializers

	public init?(string: String, range: NSRange) {
		self.range = range
		nativePrefixRange = NSRange(location: range.location, length: range.length - 1)

		let scanner = Scanner(string: string)
		scanner.charactersToBeSkipped = nil

		// url image
		if scanner.scanString("\(leadingNativePrefix)image\(trailingNativePrefix)", into: nil) {
			let urlString = (string as NSString).substring(from: 7).replacingOccurrences(of: " ", with: "%20")

			if let url = URL(string: urlString) {
				self.identifier = urlString
				self.url = url
				self.size = nil
				return
			}

			return nil
		}

		// Uploaded image delimiter
		scanner.scanLocation = 0
		if !scanner.scanString("\(leadingNativePrefix)image-", into: nil) {
			return nil
		}

		var json: NSString? = ""
		scanner.scanUpTo(trailingNativePrefix, into: &json)

		if !scanner.scanString(trailingNativePrefix, into: nil) {
			return nil
		}

		guard let data = json?.data(using: String.Encoding.utf8.rawValue),
			let raw = try? JSONSerialization.jsonObject(with: data, options: []),
			let dictionary = raw as? [String: Any]
		else {
			return nil
		}

		let urlString = (dictionary["url"] as? String)?.replacingOccurrences(of: " ", with: "%20")
		let ci = dictionary["ci"] as? String

		// We need some identifier
		guard let identifier = ci ?? urlString else { return nil }

		self.identifier = identifier
		self.url = urlString.compactMap { URL(string: $0) }

		if let width = dictionary["width"] as? UInt, let height = dictionary["height"] as? UInt {
			size = CGSize(width: Int(width), height: Int(height))
		} else {
			size = nil
		}
	}


	// MARK: - Node

	public mutating func offset(_ delta: Int) {
		range.location += delta
		nativePrefixRange.location += delta
	}


	// MARK: - Native

	public static func nativeRepresentation(URL: Foundation.URL) -> String {
		return "\(leadingNativePrefix)image\(trailingNativePrefix)\(URL.absoluteString)"
	}
}


extension Image: Hashable {
	public var hashValue: Int {
		return identifier.hashValue
	}
}


public func == (lhs: Image, rhs: Image) -> Bool {
	return NSEqualRanges(lhs.range, rhs.range) &&
		NSEqualRanges(lhs.nativePrefixRange, rhs.nativePrefixRange) &&
		lhs.identifier == rhs.identifier &&
		lhs.url == rhs.url &&
		lhs.size == rhs.size
}
