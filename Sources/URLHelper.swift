//
//  Router.swift
//  CanvasCore
//
//  Created by Sam Soffes on 8/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

public struct URLHelper {
	
	/// Extracts a canvas ID from a URL. An ID will only be extracted if it's a valid canvas URL and there isn't an
	/// extension.
	///
	/// - parameter url: A url to parse
	/// - returns: a canvas ID or nil
	public static func canvasID(url url: NSURL) -> String? {
		guard let components = url.pathComponents
		where url.pathExtension?.isEmpty ?? true && components.count == 4 else { return nil }
		return components[3]
	}
}
