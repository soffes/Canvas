import Foundation

let resourceBundle: Bundle = {
	let url = Bundle.main.resourceURL!.appendingPathComponent("CanvasCoreResources.bundle")
	return Bundle(url: url)!
}()
