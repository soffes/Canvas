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
		let components = Calendar.current.components([.second, .minute, .hour, .day, .year], fromDate: self, toDate: NSDate(), options: [])

		if components.year > 0 {
			return "\(components.year)y"
		}

		if components.day > 0 {
			return "\(components.day)d"
		}

		if components.hour > 0 {
			return "\(components.hour)h"
		}

		if components.minute > 0 {
			return "\(components.minute)m"
		}

		return "\(components.second)s"
	}
}
