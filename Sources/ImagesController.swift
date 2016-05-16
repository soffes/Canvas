//
//  ImagesController.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/25/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Cache

final class ImagesController {
	
	// MARK: - Types
	
	typealias Completion = (ID: String, image: UIImage?) -> Void
	
	
	// MARK: - Properties
	
	let session: NSURLSession
	
	private var downloading = [String: [Completion]]()
	
	private let queue = dispatch_queue_create("com.usecanvas.canvastext.imagescontroller", DISPATCH_QUEUE_SERIAL)
	
	private let memoryCache = MemoryCache<UIImage>()
	private let imageCache: MultiCache<UIImage>
	private let placeholderCache = MemoryCache<UIImage>()
	
	static let sharedController = ImagesController()
	
	
	// MARK: - Initializers
	
	init(session: NSURLSession = NSURLSession.sharedSession()) {
		self.session = session

		var caches = [AnyCache(memoryCache)]

		// Setup disk cache
		if let cachesDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first {
			let directory = (cachesDirectory as NSString).stringByAppendingPathComponent("CanvasImages") as String

			if let diskCache = DiskCache<UIImage>(directory: directory) {
				caches.append(AnyCache(diskCache))
			}
		}

		imageCache = MultiCache(caches: caches)
	}
	
	
	// MARK: - Accessing
	
	func fetchImage(ID ID: String, URL: NSURL, size: CGSize, scale: CGFloat, completion: Completion) -> UIImage? {
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
		let image = data.flatMap { UIImage(data: $0) }

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
	
	private func placeholderImage(size size: CGSize, scale: CGFloat) -> UIImage? {
		let key = "\(size.width)x\(size.height)-\(scale)"
		if let image = placeholderCache[key] {
			return image
		}
		
		guard let icon = UIImage(named: "ImagePlaceholder") else { return nil }
		
		let rect = CGRect(origin: .zero, size: size)
		
		UIGraphicsBeginImageContextWithOptions(size, true, scale ?? 0)
		
		// Background
		UIColor(red: 0.957, green: 0.976, blue: 1, alpha: 1).setFill()
		UIBezierPath(rect: rect).fill()
		
		// Icon
		UIColor(red: 0.729, green: 0.773, blue: 0.835, alpha: 1).setFill()
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
	}
}
