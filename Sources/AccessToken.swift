//
//  AccessToken.swift
//  CanvasKit
//
//  Created by Sam Soffes on 8/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

struct AccessToken {

	// MARK: - Properties

	let id: String
	let token: String
}


extension AccessToken: Resource {
	init(data: ResourceData) throws {
		id = data.id
		token = try data.decode(attribute: "token")
	}
}
