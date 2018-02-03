import CanvasNative

extension UnorderedListItem: Annotatable {
	public func annotation(theme: Theme) -> Annotation? {
		return BulletView(block: self, theme: theme)
	}
}
