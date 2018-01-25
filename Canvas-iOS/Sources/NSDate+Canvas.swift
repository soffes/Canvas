//
//  NSDate+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 12/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

extension Date {
	var briefTimeAgoInWords: String {
		let components = Calendar.current.dateComponents([.second, .minute, .hour, .day, .year], from: self, to: Date())

		if let years = components.year, years > 0 {
			return "\(years)y"
		}

		if let days = components.day, days > 0 {
			return "\(days)d"
		}

		if let hours = components.hour, hours > 0 {
			return "\(hours)h"
		}

		if let minutes = components.minute, minutes > 0 {
			return "\(minutes)m"
		}

		if let seconds = components.second, seconds > 0 {
			return "\(seconds)s"
		}

		return "now"
	}
}
