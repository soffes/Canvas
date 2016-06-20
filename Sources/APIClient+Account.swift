//
//  APIClient+Account.swift
//  CanvasKit
//
//  Created by Sam Soffes on 6/20/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

extension APIClient {

	// MARK: - Revoking Access Tokens

	public func revokeAccessToken(completion: (Result<Void> -> Void)? = nil) {
		let params = [
			"token": accessToken
		]

		let block: Result<Void> -> Void
		if let completion = completion {
			block = completion
		} else {
			block = { _ in }
		}

		request(method: .POST, path: "v1/oauth/access-tokens/actions/revoke", parameters: params, completion: block)
	}
}
