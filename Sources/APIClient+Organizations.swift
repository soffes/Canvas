//
//  APIClient+Organizations.swift
//  CanvasKit
//
//  Created by Sam Soffes on 11/13/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

extension APIClient {

	// MARK: - Listing Organizations

	public func listOrganizations(completion: Result<[Organization]> -> Void) {
		request(path: "v1/orgs", completion: completion)
	}
}
