//
//  APIClient+Account.swift
//  CanvasKit
//
//  Created by Sam Soffes on 6/20/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

extension APIClient {

	// MARK: - Revoking Access Tokens

	public func revokeAccessToken(completion: Result<Void> -> Void) {
		let params = [
			"token": accessToken
		]
		request(method: .POST, path: "v1/oauth/access-tokens/actions/revoke", parameters: params, completion: completion)
	}
}

