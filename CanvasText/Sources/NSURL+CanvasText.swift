//
//  NSURL.swift
//  CanvasText
//
//  Created by Sam Soffes on 5/31/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

extension NSURL {
	var isImageURL: Bool {
		guard let ext = pathExtension?.lowercaseString else { return false }

		let scheme = self.scheme.lowercaseString
		return (scheme == "http" || scheme == "https") && (ext == "jpg" || ext == "gif" || ext == "png" || ext == "jpeg")
	}
}