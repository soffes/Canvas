//
//  TickingLabel.swift
//  Canvas
//
//  Created by Sam Soffes on 1/28/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

final class TickingLabel: UILabel {

	// MARK: - Properties

	var date: Date? {
		didSet {
			tick()
		}
	}

	private static var timer: Timer?
	private static let tickNotification = Notification.Name(rawValue: "TickingLabel.tickNotification")
	private static var isTimerSetup = false


	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		NotificationCenter.default.addObserver(self, selector: #selector(tick), name: type(of: self).tickNotification, object: nil)

		type(of: self).setupTimer()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - Private

	private class func setupTimer() {
		if isTimerSetup {
			return
		}

		NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: .UIApplicationWillResignActive, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
		applicationDidBecomeActive()

		isTimerSetup = true
	}

	@objc private class func fire() {
		NotificationCenter.default.post(name: tickNotification, object: nil)
	}

	@objc private class func applicationWillResignActive() {
		timer?.invalidate()
		timer = nil
	}

	@objc private class func applicationDidBecomeActive() {
		let timer = Timer(timeInterval: 1, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
		timer.tolerance = 0.5
		self.timer = timer

		RunLoop.main.addTimer(timer, forMode: .commonModes)
	}

	@objc private func tick() {
		text = date?.briefTimeAgoInWords
	}
}
