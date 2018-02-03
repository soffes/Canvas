import Foundation

let resourceBundle: Bundle = {
	let url = Bundle.main.resourceURL!.appendingPathComponent("CanvasTextResources.bundle")
	return Bundle(url: url)!
}()
