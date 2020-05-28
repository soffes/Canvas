import XCTest
import CanvasNative

extension XCTest {
	func parse(_ string: String) -> [NSDictionary] {
		return Parser.parse(string).map { $0.dictionary as NSDictionary }
	}

	func blockTypes(_ string: String) -> [String] {
		return Parser.parse(string).map { String(describing: $0) }
	}
}
