import Foundation

extension URL {
	var isImageURL: Bool {
		let ext = pathExtension.lowercased()
		let scheme = self.scheme?.lowercased()
		return (scheme == "http" || scheme == "https") && (ext == "jpg" || ext == "gif" || ext == "png" || ext == "jpeg")
	}
}
