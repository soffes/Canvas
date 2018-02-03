#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import Cache
import X

final class ImagesController: Themeable {

    // MARK: - Types

	typealias Completion = (_ id: String, _ image: Image?) -> Void

    // MARK: - Properties

	var theme: Theme
	let session: URLSession

	private var downloading = [String: [Completion]]()

	private let queue = DispatchQueue(label: "com.usecanvas.canvastext.imagescontroller", qos: .background, attributes: [])

	private let memoryCache = MemoryCache<Image>()
	private let imageCache: MultiCache<Image>
	private let placeholderCache = MemoryCache<Image>()

    // MARK: - Initializers

	init(theme: Theme, session: URLSession = .shared) {
		self.theme = theme
		self.session = session

		var caches = [AnyCache(memoryCache)]

		// Setup disk cache
		if let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
			let directory = (cachesDirectory as NSString).appendingPathComponent("CanvasImages") as String

			if let diskCache = DiskCache<Image>(directory: directory) {
				caches.append(AnyCache(diskCache))
			}
		}

		imageCache = MultiCache(caches: caches)
	}

    // MARK: - Accessing

	func fetchImage(withID id: String, url: URL?, size: CGSize, scale: CGFloat, completion: @escaping Completion) -> Image? {
		if let image = memoryCache[id] {
			return image
		}

		// Get cached image or download if there's a URL
		if let url = url {
			imageCache.get(key: id) { [weak self] image in
				if let image = image {
					DispatchQueue.main.async {
						completion(id, image)
					}
					return
				}

				self?.coordinate { [weak self] in
					// Already downloading
					if var array = self?.downloading[id] {
						array.append(completion)
						self?.downloading[id] = array
						return
					}

					// Start download
					self?.downloading[id] = [completion]

					let request = URLRequest(url: url)
					self?.session.downloadTask(with: request) { [weak self] location, _, _ in
						self?.loadImage(location: location, id: id)
					}.resume()
				}
			}
		}

		return placeholderImage(size: size, scale: scale)
	}

    // MARK: - Private

	private func coordinate(_ block: () -> Void) {
		queue.sync(execute: block)
	}

	private func loadImage(location: URL?, id: String) {
		let data = location.flatMap { try? Data(contentsOf: $0) }
		let image = data.flatMap { Image(data: $0) }

		if let image = image {
			imageCache.set(key: id, value: image)
		}

		coordinate { [weak self] in
			if let image = image, let completions = self?.downloading[id] {
				for completion in completions {
					DispatchQueue.main.async {
						completion(id, image)
					}
				}
			}

			self?.downloading[id] = nil
		}
	}

	private func placeholderImage(size: CGSize, scale: CGFloat) -> Image? {
		#if os(OSX)
			// TODO: Implement
			return nil
		#else
			let key = "\(size.width)x\(size.height)-\(scale)-\(theme.imagePlaceholderColor)-\(theme.imagePlaceholderBackgroundColor)"
			if let image = placeholderCache[key] {
				return image
			}

			guard let icon = Image(named: "PhotoLandscape", in: resourceBundle) else { return nil }

			let rect = CGRect(origin: .zero, size: size)

			UIGraphicsBeginImageContextWithOptions(size, true, scale)

			// Background
			theme.imagePlaceholderBackgroundColor.setFill()
			UIBezierPath(rect: rect).fill()

			// Icon
			theme.imagePlaceholderColor.setFill()
			let iconFrame = CGRect(
				x: (size.width - icon.size.width) / 2,
				y: (size.height - icon.size.height) / 2,
				width: icon.size.width,
				height: icon.size.height
			)
			icon.draw(in: iconFrame)

			let image = UIGraphicsGetImageFromCurrentImageContext()
			placeholderCache[key] = image

			UIGraphicsEndImageContext()

			return image
		#endif
	}
}
