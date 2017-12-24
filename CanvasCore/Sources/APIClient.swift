//
//  APIClient.swift
//  CanvasCore
//
//  Created by Sam Soffes on 7/22/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasKit

public final class APIClient: CanvasKit.APIClient {
	public convenience init(account: Account, config: Configuration) {
		let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: sessionDelegate, delegateQueue: nil)
		self.init(accessToken: account.accessToken, baseURL: config.environment.apiURL, session: session)
	}

	public override func shouldComplete<T>(request request: NSURLRequest, response: NSHTTPURLResponse?, data: NSData?, error: NSError?, completion: (Result<T> -> Void)?) -> Bool {
		// TODO: Remove 400 once the API updates
		if response?.statusCode == 400 || response?.statusCode == 401 {
			dispatch_async(dispatch_get_main_queue()) {
				AccountController.sharedController.currentAccount = nil
			}
			return false
		}

		return super.shouldComplete(request: request, response: response, data: data, error: error, completion: completion)
	}
}
