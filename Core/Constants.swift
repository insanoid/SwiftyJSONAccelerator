//
//  Constants.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 01/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

/**
Various supported variable types

- String:       String.
- Int:          Integer.
- Float:        Float.
- Double: 		 Double.
- Bool:         Boolean.
- Array:        Array.
- Object:       Object.
*/
enum VariableType: String {
	case string = "String"
	case int = "Int"
	case float = "Float"
	case double = "Double"
	case bool = "Bool"
	case array = "[]"
	case object = "{OBJ}"
	case null = "Any"
}

/**
Various types of construct that can be generated.

- ClassType:  Model with construct type class.
- StructType: Model with construct type struct.
*/
enum ConstructType: String {
	case classType = "class"
	case structType = "struct"
}

/**
List of supported mapping libraries.

- SwiftyJSON:   SwiftyJSON - https://github.com/SwiftyJSON/SwiftyJSON
- ObjectMapper: ObjectMapper - https://github.com/Hearst-DD/ObjectMapper
- Marshal: Marshal - https://github.com/utahiosmac/Marshal
*/
enum JSONMappingLibrary: String {
	case swiftyJSON = "SwiftyJSON"
	case objectMapper = "ObjectMapper"
	case marshal = "Marshal"
	case swift4 = "Swift4"
}

/**
Types of property.

- Value:       Value type like String, Integer, Float etc.
- ValueArray:  Array of Value
- Object:      Object type
- ObjectArray: Array of object
- EmptyArray:  An empty array
- Null:        Null value
*/
enum PropertyType: String {
	case valueType = "ValueType"
	case valueTypeArray = "ValueTypeArray"
	case objectType = "ObjectType"
	case objectTypeArray = "ObjectTypeArray"
	case emptyArray = "EmptyArray"
	case nullType = "NullType"
}
