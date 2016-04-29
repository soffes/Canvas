//
//  HorizontalRuleAttachment.swift
//  CanvasText
//
//  Created by Sam Soffes on 4/29/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

struct HorizontalRuleAttachment {
	
	private static let height: CGFloat = 1
	
	static func image(width width: CGFloat, theme: Theme) -> UIImage? {
		// Create context
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue).rawValue
		let context = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo)
		
		// Draw
		CGContextSetFillColorWithColor(context, theme.horizontalRuleColor.CGColor)
		CGContextFillRect(context, CGRect(x: 0, y: 0, width: width, height: height))
		
		// Return image
		let image = CGBitmapContextCreateImage(context)
		return image.flatMap { UIImage(CGImage: $0) }
	}
}
