//
//  Configuration.swift
//  CanvasCore
//
//  Created by Sam Soffes on 12/2/15.
//  Copyright © 2015–2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public enum Environment: String {
	case development
	case staging
	case production

	public var baseURL: NSURL {
		switch self {
		case .development: return NSURL(string: "http://localhost:5001/")!
		case .staging: return NSURL(string: "https://canvas-api-staging.herokuapp.com/")!
		case .production: return NSURL(string: "https://api.usecanvas.com/")!
		}
	}

	public var realtimeURL: NSURL {
		switch self {
		case .development: return NSURL(string: "ws://localhost:5002/")!
		case .staging: return NSURL(string: "wss://canvas-realtime-staging.herokuapp.com/")!
		case .production: return NSURL(string: "wss://realtime.usecanvas.com/")!
		}
	}

	public var presenceURL: NSURL {
		switch self {
		case .development: return NSURL(string: "ws://localhost:5003/")!
		case .staging: return NSURL(string: "wss://canvas-live-staging.herokuapp.com/")!
		case .production: return NSURL(string: "wss://live.usecanvas.com/")!
		}
	}
}


public struct Configuration {

	// MARK: - Canvas

	/// Canvas environment
	public let environment: Environment

	/// Canvas client ID
	public let canvasClientID: String
	
	/// Canvas client secret
	public let canvasClientSecret: String
	
	
	// MARK: - Imgix
	
	/// Imgix host for linked images
	public let imgixProxyHost = "canvas-proxy.imgix.net"
	
	/// Imgix secret for linked images
	public let imgixProxySecret = "dKSsF9Z87FCvTOY7"
	
	/// Imgix host for uploaded images
	public let imgixUploadHost = "canvas-uploads.imgix.net"
	
	/// Imgix secret for uploaded images
	public let imgixUploadSecret = "nfEHTw0lmtfOQo4Q"


	// MARK: - Analytics & Crash Reporting

	/// Mixpanel token
	public let mixpanelToken = "447ae99e6cff699db67f168818c1dbf9"

	/// Sentry
	public let sentryDSN = "https://1bc50d7449e448029db4c5cb79d89c51:2648877a36ae4f5cb6ca51ba9dc82a3e@app.getsentry.com/76374"


	// MARK: - Applications

	#if INTERNAL
		public let updatesURL = NSURL(string: "https://beta.itunes.apple.com/v1/app/1106990374")!
	#elseif BETA
		public let updatesURL = NSURL(string: "https://beta.itunes.apple.com/v1/app/1060281423")!
	#else
		public let updatesURL = NSURL(string: "https://itunes.apple.com/app/canvas-for-ios/id1060281423?ls=1&mt=8")!
	#endif


	// MARK: - Initializers

	public init(environment: Environment = .production, canvasClientID: String, canvasClientSecret: String) {
		self.environment = environment
		self.canvasClientID = canvasClientID
		self.canvasClientSecret = canvasClientSecret
	}
}
