import CanvasNative

extension OrderedListItem: Annotatable {
	public func annotation(theme: Theme) -> Annotation? {
		return NumberView(block: self, theme: theme)
	}
}
