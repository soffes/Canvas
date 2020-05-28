import CanvasNative

extension CodeBlock: Annotatable {
	public func annotation(theme: Theme) -> Annotation? {
		return CodeBlockView(block: self, theme: theme)
	}
}
