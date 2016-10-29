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
  case String = "String"
  case Int = "Int"
  case Float = "Float"
  case Double = "Double"
  case Bool = "Bool"
  case Array = "[]"
  case Object = "{OBJ}"
  case Null = "Any"
}

/**
 Various types of construct that can be generated.

 - ClassType:  Model with construct type class.
 - StructType: Model with construct type struct.
 */
enum ConstructType: String {
  case ClassType = "class"
  case StructType = "struct"
}

/**
 List of supported mapping libraries.

 - SwiftyJSON:   SwiftyJSON - https://github.com/SwiftyJSON/SwiftyJSON
 - ObjectMapper: ObjectMapper - https://github.com/Hearst-DD/ObjectMapper
 */
enum JSONMappingLibrary: String {
  case SwiftyJSON
  case ObjectMapper
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
  case ValueType
  case ValueTypeArray
  case ObjectType
  case ObjectTypeArray
  case EmptyArray
  case NullType
}
