//
//  HorizontalRuleAttachment.swift
//  CanvasText
//
//  Created by Sam Soffes on 4/29/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

struct HorizontalRuleAttachment {
	
	static let height: CGFloat = 19
	
	static func image(theme theme: Theme) -> UIImage? {
		let width: CGFloat = 1

		// Create context
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue).rawValue
		let context = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo)

		// Background
		CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
		CGContextFillRect(context, CGRect(x: 0, y: 0, width: width, height: height))
		
		// Line
		CGContextSetFillColorWithColor(context, theme.horizontalRuleColor.CGColor)
		CGContextFillRect(context, CGRect(x: 0, y: ((height - 1) / 2) - 2, width: width, height: 1))
		
		// Create image
		guard let cgImage = CGBitmapContextCreateImage(context) else { return nil }
		let image = UIImage(CGImage: cgImage)
		
		// Return image
		return image
	}
}
