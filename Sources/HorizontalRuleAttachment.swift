//
//  HorizontalRuleAttachment.swift
//  CanvasText
//
//  Created by Sam Soffes on 4/29/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

struct HorizontalRuleAttachment {
	
	static let height: CGFloat = 1
	
	static func image(theme theme: Theme) -> UIImage? {
		// Create context
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue).rawValue
		let context = CGBitmapContextCreate(nil, Int(height), Int(height), 8, 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo)
		
		// Draw
		CGContextSetFillColorWithColor(context, theme.horizontalRuleColor.CGColor)
		CGContextFillRect(context, CGRect(x: 0, y: 0, width: height, height: height))
		
		// Create image
		guard let cgImage = CGBitmapContextCreateImage(context) else { return nil }
		let image = UIImage(CGImage: cgImage)
		
		// Return image
		return image
	}
}
