//
//  ImagesController.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/25/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import Cache
import X

final class ImagesController: Themeable {
	
	// MARK: - Types
	
	typealias Completion = (ID: String, image: Image?) -> Void
	
	
	// MARK: - Properties

	var theme: Theme
	let session: NSURLSession
	
	private var downloading = [String: [Completion]]()
	
	private let queue = dispatch_queue_create("com.usecanvas.canvastext.imagescontroller", DISPATCH_QUEUE_SERIAL)
	
	private let memoryCache = MemoryCache<Image>()
	private let imageCache: MultiCache<Image>
	private let placeholderCache = MemoryCache<Image>()
	
	
	// MARK: - Initializers
	
	init(theme: Theme, session: NSURLSession = NSURLSession.sharedSession()) {
		self.theme = theme
		self.session = session

		var caches = [AnyCache(memoryCache)]

		// Setup disk cache
		if let cachesDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first {
			let directory = (cachesDirectory as NSString).stringByAppendingPathComponent("CanvasImages") as String

			if let diskCache = DiskCache<Image>(directory: directory) {
				caches.append(AnyCache(diskCache))
			}
		}

		imageCache = MultiCache(caches: caches)
	}
	
	
	// MARK: - Accessing
	
	func fetchImage(ID ID: String, URL: NSURL, size: CGSize, scale: CGFloat, completion: Completion) -> Image? {
		if let image = memoryCache[ID] {
			return image
		}

		imageCache.get(key: ID) { [weak self] image in
			if let image = image {
				dispatch_async(dispatch_get_main_queue()) {
					completion(ID: ID, image: image)
				}
				return
			}

			self?.coordinate { [weak self] in
				// Already downloading
				if var array = self?.downloading[ID] {
					array.append(completion)
					self?.downloading[ID] = array
					return
				}

				// Start download
				self?.downloading[ID] = [completion]

				let request = NSURLRequest(URL: URL)
				self?.session.downloadTaskWithRequest(request) { [weak self] location, _, _ in
					self?.loadImage(location: location, ID: ID)
				}.resume()
			}
		}

		return placeholderImage(size: size, scale: scale)
	}
	
	
	// MARK: - Private
	
	private func coordinate(block: dispatch_block_t) {
		dispatch_sync(queue, block)
	}
	
	private func loadImage(location location: NSURL?, ID: String) {
		let data = location.flatMap { NSData(contentsOfURL: $0) }
		let image = data.flatMap { Image(data: $0) }

		if let image = image {
			imageCache.set(key: ID, value: image)
		}

		coordinate { [weak self] in
			if let image = image, completions = self?.downloading[ID] {
				for completion in completions {
					dispatch_async(dispatch_get_main_queue()) {
						completion(ID: ID, image: image)
					}
				}
			}

			self?.downloading[ID] = nil
		}
	}
	
	private func placeholderImage(size size: CGSize, scale: CGFloat) -> Image? {
		#if os(OSX)
			return nil
		#else
			let key = "\(size.width)x\(size.height)-\(scale)-\(theme.placeholderColor)-\(theme.placeholderImageBackgroundColor)"
			if let image = placeholderCache[key] {
				return image
			}
			
			guard let icon = Image(named: "ImagePlaceholder") else { return nil }
			
			let rect = CGRect(origin: .zero, size: size)
			
			UIGraphicsBeginImageContextWithOptions(size, true, scale ?? 0)
			
			// Background
			theme.placeholderImageBackgroundColor.setFill()
			UIBezierPath(rect: rect).fill()
			
			// Icon
			theme.placeholderColor.setFill()
			let iconFrame = CGRect(
				x: (size.width - icon.size.width) / 2,
				y: (size.height - icon.size.height) / 2,
				width: icon.size.width,
				height: icon.size.height
			)
			icon.drawInRect(iconFrame)
			
			let image = UIGraphicsGetImageFromCurrentImageContext()
			placeholderCache[key] = image
			
			UIGraphicsEndImageContext()
			
			return image
		#endif
	}
}
