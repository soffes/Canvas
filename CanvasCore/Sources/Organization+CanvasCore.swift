//
//  Organization+CanvasCore.swift
//  CanvasCore
//
//  Created by Sam Soffes on 8/30/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasKit

public extension Organization {
	public var isPersonalNotes: Bool {
		guard let account = AccountController.sharedController.currentAccount else { return false }
		return slug == account.user.username
	}

	public var displayName: String {
		return isPersonalNotes ? LocalizedString.PersonalNotes.string : name
	}
}
