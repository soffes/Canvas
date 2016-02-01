//
//  NetworkClient.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/13/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

let baseURL = NSURL(string: "https://api.usecanvas.com")!
let networkCompletionQueue = dispatch_queue_create("com.usecanvas.canvaskit.network-callback", DISPATCH_QUEUE_CONCURRENT)


public protocol NetworkClient {

	var baseURL: NSURL { get }
	var session: NSURLSession { get }
}


public enum Result<T> {
	case Success(T)
	case Failure(String)
}
