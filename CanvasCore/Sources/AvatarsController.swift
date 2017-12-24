//
//  AvatarsController.swift
//  CanvasCore
//
//  Created by Sam Soffes on 6/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Cache
import X

public final class AvatarsController {

	// MARK: - Types

	public typealias Completion = (id: String, image: Image?) -> Void


	// MARK: - Properties

	public static let sharedController = AvatarsController()

	public let session: NSURLSession

	private var downloading = [String: [Completion]]()
	private let queue = dispatch_queue_create("com.usecanvas.canvas.avatarscontroller", DISPATCH_QUEUE_SERIAL)
	private let memoryCache = MemoryCache<Image>()
	private let imageCache: MultiCache<Image>
	private let placeholderCache = MemoryCache<Image>()


	// MARK: - Initializers

	public init(session: NSURLSession = NSURLSession.sharedSession()) {
		self.session = session

		var caches = [AnyCache(memoryCache)]

		// Setup disk cache
		if let cachesDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first {
			let directory = (cachesDirectory as NSString).stringByAppendingPathComponent("CanvasAvatars") as String

			if let diskCache = DiskCache<Image>(directory: directory) {
				caches.append(AnyCache(diskCache))
			}
		}

		imageCache = MultiCache(caches: caches)
	}


	// MARK: - Accessing

	public func fetchImage(id id: String, url: NSURL, completion: Completion) -> Image? {
		if let image = memoryCache[id] {
			return image
		}

		imageCache.get(key: id) { [weak self] image in
			if let image = image {
				dispatch_async(dispatch_get_main_queue()) {
					completion(id: id, image: image)
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

				let request = NSURLRequest(URL: url)
				self?.session.downloadTaskWithRequest(request) { [weak self] location, _, _ in
					self?.loadImage(location: location, id: id)
				}.resume()
			}
		}

		return nil
	}


	// MARK: - Private

	private func coordinate(block: dispatch_block_t) {
		dispatch_sync(queue, block)
	}

	private func loadImage(location location: NSURL?, id: String) {
		let data = location.flatMap { NSData(contentsOfURL: $0) }
		let image = data.flatMap { Image(data: $0) }

		if let image = image {
			imageCache.set(key: id, value: image)
		}

		coordinate { [weak self] in
			if let image = image, completions = self?.downloading[id] {
				for completion in completions {
					dispatch_async(dispatch_get_main_queue()) {
						completion(id: id, image: image)
					}
				}
			}

			self?.downloading[id] = nil
		}
	}
}
