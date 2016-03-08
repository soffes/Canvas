//
//  AppDelegate.swift
//  Example
//
//  Created by Sam Soffes on 2/17/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow? = UIWindow()

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// FIXME: Add your access token here
//		NSUserDefaults.standardUserDefaults().setObject("YOUR_ACCESS_TOKEN_HERE", forKey: "AccessToken")

		window?.rootViewController = UINavigationController(rootViewController: ViewController())
		window?.makeKeyAndVisible()
		return true
	}
}
