//
//  File.swift
//  CanvasText
//
//  Created by Sam Soffes on 12/30/17.
//

import Foundation

let resourceBundle: Bundle = {
	let path = (Bundle.main.resourcePath! as NSString).appendingPathComponent("CanvasTextResources")
	return Bundle(path: path)!
}()
