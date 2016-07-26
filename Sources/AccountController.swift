//
//  AccountController.swift
//  CanvasCore
//
//  Created by Sam Soffes on 11/3/15.
//  Copyright © 2015–2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasKit
import SAMKeychain

public class AccountController {

	// MARK: - Properties

	public var currentAccount: Account? {
		didSet {
			if let account = currentAccount, data = try? NSJSONSerialization.dataWithJSONObject(account.dictionary, options: []) {
				SAMKeychain.setPasswordData(data, forService: "Canvas", account: "Account")
			} else {
				SAMKeychain.deletePasswordForService("Canvas", account: "Account")
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
		guard let data = SAMKeychain.passwordDataForService("Canvas", account: "Account") else { return }

		guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
			dictionary = json as? JSONDictionary,
			account = Account(dictionary: dictionary)
		else {
			SAMKeychain.deletePasswordForService("Canvas", account: "Account")
			return
		}

		currentAccount = account
	}
}
