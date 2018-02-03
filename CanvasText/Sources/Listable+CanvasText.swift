import CanvasNative

extension Indentation {
	var isFilled: Bool {
		return rawValue % 2 == 0
	}
}
