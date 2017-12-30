//
//  Swatch.swift
//  CanvasCore
//
//  Created by Sam Soffes on 11/12/15.
//  Copyright © 2015–2016 Canvas Labs, Inc. All rights reserved.
//

import X

public struct Swatch {

	// MARK: - Base

	public static let black = Color(red: 0.161, green: 0.180, blue: 0.192, alpha: 1)
	public static let white = Color.white
	public static let darkGray = Color(red: 0.514, green: 0.569, blue: 0.592, alpha: 1)
	public static let gray = Color(red: 0.752, green: 0.796, blue: 0.821, alpha: 1)
	public static let lightGray = Color(red: 0.906, green: 0.918, blue: 0.925, alpha: 1)
	public static let extraLightGray = Color(red: 0.961, green: 0.969, blue: 0.976, alpha: 1)

	fileprivate static let blue = Color(red: 0.255, green:0.306, blue: 0.976, alpha: 1)
	public static let lightBlue = Color(red: 0.188, green: 0.643, blue: 1, alpha: 1)
	public static let green = Color(red: 0.157, green:0.859, blue: 0.404, alpha: 1)
	fileprivate static let pink = Color(red: 1, green: 0.216, blue: 0.502, alpha: 1)
	fileprivate static let yellow = Color(red: 1, green: 0.942, blue: 0.716, alpha: 1)


	// MARK: - Shared

	public static let brand = blue
	public static let destructive = pink
	public static let comment = yellow


	// MARK: - Bars

	public static let border = gray


	// MARK: - Tables

	public static let groupedTableBackground = extraLightGray

	/// Chevron in table view cells
	public static let cellDisclosureIndicator = darkGray
}
