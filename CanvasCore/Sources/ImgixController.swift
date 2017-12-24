//
//  ImgixController.swift
//  CanvasCore
//
//  Created by Sam Soffes on 6/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct ImgixController {
	public static func sign(url url: NSURL, parameters: [NSURLQueryItem]? = nil, configuration: Configuration) -> NSURL? {
		let defaultParameters = [
			NSURLQueryItem(name: "fm", value: "jpg"),
			NSURLQueryItem(name: "q", value: "80")
		]

		// Uploaded image
		let uploadPrefix = "https://canvas-files-prod.s3.amazonaws.com/uploads/"
		if url.absoluteString.hasPrefix(uploadPrefix) {
			let imgix = Imgix(host: configuration.imgixUploadHost, secret: configuration.imgixUploadSecret, defaultParameters: defaultParameters)
			let path = (url.absoluteString as NSString).substringFromIndex((uploadPrefix as NSString).length)
			return imgix.sign(path: path)
		}

		// Linked image
		let imgix = Imgix(host: configuration.imgixProxyHost, secret: configuration.imgixProxySecret, defaultParameters: defaultParameters)
		let path = url.absoluteString.stringByAddingPercentEncodingWithAllowedCharacters(.URLPathAllowedCharacterSet())
		return path.flatMap { imgix.sign(path: $0) }
	}
}
