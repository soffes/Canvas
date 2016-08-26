//
//  APIClient+Canvas.swift
//  CanvasCore
//
//  Created by Sam Soffes on 7/22/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasKit

extension CanvasCore.APIClient {
	public convenience init(account: Account) {
		self.init(account: account, config: config)
	}
}
