//
//  AccountController.swift
//  CanvasCore
//
//  Created by Sam Soffes on 11/3/15.
//  Copyright © 2015–2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasKit
import SSKeychain

public class AccountController {

	// MARK: - Properties

	public var currentAccount: Account? {
		didSet {
			if let account = currentAccount, data = try? NSJSONSerialization.dataWithJSONObject(account.dictionary, options: []) {
				SSKeychain.setPasswordData(data, forService: "Canvas", account: "Account")
			} else {
				SSKeychain.deletePasswordForService("Canvas", account: "Account")
				NSUserDefaults.standardUserDefaults().removeObjectForKey("Organizations")
				NSUserDefaults.standardUserDefaults().removeObjectForKey("SelectedOrganization")
			}

			NSNotificationCenter.defaultCenter().postNotificationName(self.dynamicType.accountDidChangeNotificationName, object: nil)
		}
	}

	public static let accountDidChangeNotificationName = "AccountController.accountDidChangeNotification"

	public static let sharedController = AccountController()


	// MARK: - Initializers

	init() {
		guard let data = SSKeychain.passwordDataForService("Canvas", account: "Account") else { return }

		guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
			dictionary = json as? JSONDictionary,
			account = Account(dictionary: dictionary)
		else {
			SSKeychain.deletePasswordForService("Canvas", account: "Account")
			return
		}

		currentAccount = account
	}
}
