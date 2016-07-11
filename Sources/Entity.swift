//
//  Entity.swift
//  CanvasKit
//
//  Created by Sam Soffes on 7/11/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import ISO8601

typealias Attributes = [String: AnyObject]
typealias Includes = [EntityType: [String: Entity]]
typealias Relationships = [String: AnyObject]

protocol Entity {
	var id: String { get }
	init(data: EntityData) throws
}


enum EntityType: String {
	case organization = "orgs"
	case canvas = "canvas"
	
	var entity: Entity.Type {
		switch self {
		case .organization: return Organization.self
		case .canvas: return Canvas.self
		}
	}
}


enum EntityError: ErrorType {
	case missingAttribute(String)
	case missingInclude(EntityType)
	case missingReleationship(String)
}

struct Releationship {
	let type: EntityType
	let id: String
	
	init?(dictionary: JSONDictionary) {
		guard let id = dictionary["id"] as? String,
			type = (dictionary["type"] as? String).flatMap(EntityType.init)
		else { return nil }
		
		self.id = id
		self.type = type
	}
}


struct EntityData {
	let type: EntityType
	let id: String
	let attributes: JSONDictionary
	let relationships: [String: Releationship]?
	let includes: Includes?
	
	init?(dictionary: JSONDictionary, includes: Includes? = nil) {
		guard let id = dictionary["id"] as? String,
			type = (dictionary["type"] as? String).flatMap(EntityType.init),
			attributes = dictionary["attributes"] as? JSONDictionary
		else { return nil }
		
		self.id = id
		self.type = type
		self.attributes = attributes
		
		if let rels = dictionary["relationships"] as? [String: JSONDictionary] {
			var relationships = [String: Releationship]()
			for (key, dictionary) in rels {
				guard let relationship = Releationship(dictionary: dictionary) else { continue }
				relationships[key] = relationship
			}
			self.relationships = relationships
		} else {
			relationships = nil
		}
		
		self.includes = includes
	}
	
	func decode<T>(attribute key: String) throws -> T {
		guard let attribute = attributes[key] as? T else {
			throw EntityError.missingAttribute(key)
		}
		return attribute
	}
	
	func decode<T>(attribute key: String) -> T? {
		return attributes[key] as? T
	}
	
	func decode(attribute key: String) throws -> NSDate {
		guard let iso8601 = attributes[key] as? String,
			date = NSDate(ISO8601String: iso8601)
			else {
				throw EntityError.missingAttribute(key)
		}
		return date
	}
	
	func decode(attribute key: String) -> NSDate? {
		let iso8601 = attributes[key] as? String
		return iso8601.flatMap { NSDate(ISO8601String: $0) }
	}
	
	func decode<T>(relationship key: String) throws -> T {
		guard let relationship = relationships?[key] else {
			throw EntityError.missingReleationship(key)
		}
		
		guard let entity = includes?[relationship.type]?[relationship.id] as? T else {
			throw EntityError.missingInclude(relationship.type)
		}
		
		return entity
	}
}


struct EntitySerialization {
	private static func includes(dictionary: JSONDictionary) -> Includes? {
		guard let array = dictionary["included"] as? [JSONDictionary] else { return nil }
		var includes = Includes()
		
		for dictionary in array {
			guard let type = (dictionary["type"] as? String).flatMap(EntityType.init),
				data = EntityData(dictionary: dictionary),
				entity = try? type.entity.init(data: data)
			else { continue }
			
			if includes[type] == nil {
				includes[type] = [:]
			}
			
			includes[type]?[entity.id] = entity
		}
		
		return includes
	}
	
	static func deserialize<T: Entity>(dictionary dictionary: JSONDictionary) -> [T]? {
		guard let datas = dictionary["data"] as? [JSONDictionary] else { return nil }
		
		let includes = self.includes(dictionary)
		
		return datas.flatMap { data in
			guard let entityData = EntityData(dictionary: data, includes: includes),
				entity = try? entityData.type.entity.init(data: entityData)
			else { return nil }
			
			return entity as? T
		}
	}
	
//	static func deserialize<T: Entity>(dictionary dictionary: JSONDictionary) -> T? {
//		guard let data = dictionary["data"] as? JSONDictionary else { return nil }
//		
//		let includes = self.includes(dictionary)
//		
//		guard let entityData = EntityData(dictionary: data, includes: includes),
//			entity = try? entityData.type.entity.init(data: entityData)
//		else { return nil }
//		
//		return entity as? T
//	}
}

