import CanvasNative

extension ChecklistItem: Annotatable {
	public func annotation(theme: Theme) -> Annotation? {
		return CheckboxView(block: self, theme: theme)
	}
}
