import CanvasNative

extension Blockquote: Annotatable {
	public func annotation(theme: Theme) -> Annotation? {
		return BlockquoteBorderView(block: self, theme: theme)
	}
}
