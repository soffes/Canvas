//
//  SessionDelegate.swift
//  CanvasCore
//
//  Created by Sam Soffes on 7/22/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

/// Internal class for SSL pinning
final class SessionDelegate: NSObject, NSURLSessionDelegate {
	func URLSession(session: NSURLSession,  didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
		guard let serverTrust = challenge.protectionSpace.serverTrust,
			certificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
			path = bundle.pathForResource("STAR_usecanvas_com", ofType: "der"),
			localCertificate = NSData(contentsOfFile: path)
		else {
			completionHandler(.CancelAuthenticationChallenge, nil)
			return
		}

		// Set SSL policies for domain name check
		let policies = NSMutableArray()
		policies.addObject(SecPolicyCreateSSL(true, (challenge.protectionSpace.host)))
		SecTrustSetPolicies(serverTrust, policies);

		// Evaluate server certificate
		var result: SecTrustResultType = 0
		SecTrustEvaluate(serverTrust, &result)
		let isServerTrusted = (Int(result) == kSecTrustResultUnspecified || Int(result) == kSecTrustResultProceed)

		// Get local and remote cert data
		let remoteCertificateData:NSData = SecCertificateCopyData(certificate)

		if (isServerTrusted && remoteCertificateData.isEqualToData(localCertificate)) {
			let credential = NSURLCredential(forTrust: serverTrust)
			completionHandler(.UseCredential, credential)
			return
		}

		completionHandler(.CancelAuthenticationChallenge, nil)
	}
}

let sessionDelegate = SessionDelegate()
