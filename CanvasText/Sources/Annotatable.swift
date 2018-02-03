import CanvasNative

public protocol Annotatable: BlockNode {
	func annotation(theme: Theme) -> Annotation?
}
