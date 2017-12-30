//
//  URL+CanvasText.swift
//  CanvasText
//
//  Created by Sam Soffes on 5/31/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

extension URL {
	var isImageURL: Bool {
		let ext = pathExtension.lowercased()
		let scheme = self.scheme?.lowercased()
		return (scheme == "http" || scheme == "https") && (ext == "jpg" || ext == "gif" || ext == "png" || ext == "jpeg")
	}
}
