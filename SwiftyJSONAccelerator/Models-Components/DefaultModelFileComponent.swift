//
//  DefaultModelFileComponent.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 02/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

/**
 *  Protocol for default file component generation. It is the fall back if the library does not want to customise the methods.
 */
protocol DefaultModelFileComponent {

  /**
   Generate the Constant declaration for the keys.

   - parameter constantName: Key provided by the API.
   - parameter value:        Value for the constant, the actual key which the model would use.

   - returns: Generated instance of the string for declaration.
   */
  func genStringConstant(constantName: String, _ value: String) -> String

  /**
   Generate a basic declaration for a variable of any kind.

   - parameter name:    Name of the variable.
   - parameter type:    Type of the variable.
   - parameter isArray: Is this an array of the given type.

   - returns: Generated instance of the string for declaration.
   */
  func genVariableDeclaration(name: String, _ type: String, _ isArray: Bool) -> String

  /**
   Generate a basic declaration for a variable of simple value type of atomic nature.

   - parameter name:    Name of the variable.
   - parameter type:    Type of the variable.

   - returns: Generated instance of the string for declaration.
   */
  func genPrimitiveVariableDeclaration(name: String, _ type: String) -> String

  /**
   Description for the primitive type variable.

   - parameter name:         Name of the variable.
   - parameter type:         Type of the variable.
   - parameter constantName: Constant name

   - returns: Generated instance of the string for description.
   */
  func genDescriptionForPrimitive(name: String, _ type: String, _ constantName: String) -> String

  /**
   Description for an array primitive type variable.

   - parameter name:         Name of the variable.
   - parameter type:         Type of the variable.
   - parameter constantName: Constant name

   - returns: Generated instance of the string for description.
   */
  func genDescriptionForPrimitiveArray(name: String, _ constantName: String) -> String

  /**
   Description for an object.

   - parameter name:         Name of the object.
   - parameter type:         Type of the object.
   - parameter constantName: Constant name

   - returns: Generated instance of the string for description.
   */
  func genDescriptionForObject(name: String, _ constantName: String) -> String

  /**
   Description for an array of a type of object.

   - parameter name:         Name of the object.
   - parameter type:         Type of the object.
   - parameter constantName: Constant name

   - returns: Generated instance of the string for description.
   */
  func genDescriptionForObjectArray(name: String, _ constantName: String) -> String

  /**
   Generate the encoder string for the given variable.

   - parameter name:         Name of the object.
   - parameter type:         Type of the object.
   - parameter constantName: Constant name
   - parameter isArray: Is this an array of the given type.

   - returns:  Generated instance of the string for decoder.
   */
  func genEncoder(name: String, _ type: String, _ constantName: String) -> String

  /**
   Generate the decoder string for the given variable.

   - parameter name:         Name of the object.
   - parameter type:         Type of the object.
   - parameter constantName: Constant name
   - parameter isArray: Is this an array of the given type.

   - returns:  Generated instance of the string for decoder.
   */
  func genDecoder(name: String, _ type: String, _ constantName: String, _ isArray: Bool) -> String
}

extension DefaultModelFileComponent {

  func genStringConstant(constantName: String, _ value: String) -> String {
    return "private let \(constantName): String = \"\(value)\""
  }

  func genVariableDeclaration(name: String, _ type: String, _ isArray: Bool) -> String {
    var _type = type
    if isArray {
      _type = "[\(type)]"
    }
    return genPrimitiveVariableDeclaration(name, _type)
  }

  func genPrimitiveVariableDeclaration(name: String, _ type: String) -> String {
    if type == VariableType.Bool.rawValue {
      return "public var \(name): \(type) = false"
    }
    return "public var \(name): \(type)?"
  }

  func genDescriptionForPrimitive(name: String, _ type: String, _ constantName: String) -> String {
    if type == VariableType.Bool.rawValue {
      return "dictionary.updateValue(\(name), forKey: \(constantName))"
    }
    return "if let value = \(name) { dictionary.updateValue(value, forKey: \(constantName)) }"
  }
  func genDescriptionForPrimitiveArray(name: String, _ constantName: String) -> String {
    return "if let value = \(name) { dictionary.updateValue(value, forKey: \(constantName)) }"
  }

  func genDescriptionForObject(name: String, _ constantName: String) -> String {
    return "if let value = \(name) { dictionary.updateValue(value.dictionaryRepresentation(), forKey: \(constantName)) }"
  }

  func genDescriptionForObjectArray(name: String, _ constantName: String) -> String {
    return "if let value = \(name) { dictionary.updateValue(value.map { $0.dictionaryRepresentation() }, forKey: \(constantName)) }"
  }

  func genEncoder(name: String, _ type: String, _ constantName: String) -> String {
    if type == VariableType.Bool.rawValue {
      return "aCoder.encodeBool(\(name), forKey: \(constantName))"
    }
    return "aCoder.encodeObject(\(name), forKey: \(constantName))"
  }

  func genDecoder(name: String, _ type: String, _ constantName: String, _ isArray: Bool) -> String {
    let finalConstantName = isArray ? "[\(constantName)]" : constantName
    if type == VariableType.Bool.rawValue {
      return "self.\(name) = aDecoder.decodeBoolForKey(\(finalConstantName))"
    }
    return "self.\(name) = aDecoder.decodeObjectForKey(\(finalConstantName)) as? \(type)"
  }

}
