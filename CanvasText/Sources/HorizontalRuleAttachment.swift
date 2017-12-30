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
	
	static func image(theme: Theme) -> UIImage? {
		let width: CGFloat = 1

		// Create context
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue
		guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo) else {
			return nil
		}

		// Background
		context.setFillColor(theme.backgroundColor.cgColor)
		context.fill(CGRect(x: 0, y: 0, width: width, height: height))
		
		// Line
		context.setFillColor(theme.horizontalRuleColor.cgColor)
		context.fill(CGRect(x: 0, y: ((height - 1) / 2) - 2, width: width, height: 1))
		
		// Create image
		guard let cgImage = context.makeImage() else { return nil }
		let image = UIImage(cgImage: cgImage)
		
		// Return image
		return image
	}
}
