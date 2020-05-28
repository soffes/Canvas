import Foundation

protocol SpanNodeParseable: SpanNode {
	static var regularExpression: NSRegularExpression { get }

	init?(match: NSTextCheckingResult)
}
