//
//  Message.swift
//  OperationalTransformation
//
//  Created by Sam Soffes on 2/2/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

enum Message {
	case operation(operation: Operation)
	case snapshot(content: String)
	case error(message: String?, lineNumber: UInt?, columnNumber: UInt?)
	case disconnect(message: String?)

	init?(dictionary: [String: AnyObject]) {
		guard let type = dictionary["type"] as? String else { return nil }

		if type == "operation", let dict = dictionary["operation"] as? [String: AnyObject], operation = Operation(dictionary: dict) {
			self = .operation(operation: operation)
			return
		}

		if type == "snapshot", let content = dictionary["content"] as? String {
			self = .snapshot(content: content)
			return
		}

		if type == "error" {
			self = .error(message: dictionary["message"] as? String, lineNumber: dictionary["line_number"] as? UInt, columnNumber: dictionary["column_number"] as? UInt)
			return
		}

		if type == "disconnect" {
			self = .disconnect(message: dictionary["message"] as? String)
			return
		}

		return nil
	}
}
