import Foundation

let resourceBundle: Bundle = {
	let path = (Bundle.main.resourcePath! as NSString).appendingPathComponent("CanvasTextResources")
	return Bundle(path: path)!
}()
