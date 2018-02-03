public protocol Renderer {
	init(document: Document)
	func render() -> String
}
