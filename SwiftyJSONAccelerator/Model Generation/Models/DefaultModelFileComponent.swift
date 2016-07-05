//
//  DefaultModelFileComponent.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 02/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

/**
 *  Protocol for default file component generation.
 */
protocol DefaultModelFileComponent {

  /**
   Generate the Constant declaration for the keys.

   - parameter constantName: Variable name for the constant.
   - parameter value:        Value for the constant, the actual key which the model would use.

   - returns: Generated instance of the string for declaration.
   */
  func genStringConstant(constantName: String, _ value: String) -> String

}

extension DefaultModelFileComponent {

  func genStringConstant(constantName: String, _ value: String) -> String {
    return "internal let \(constantName): String = \"\(value)\""
  }

  func genEncoder(name: String, _ type: String, _ constantName: String) -> String {
    if type == VariableType.Bool.rawValue {
      return "aCoder.encodeBool(\(name), forKey: \(constantName))"
    }
    return "aCoder.encodeObject(\(name), forKey: \(constantName))"
  }

  func genDescriptionForPrimitive(name: String, _ type: String, _ constantName: String) -> String {
    if type == VariableType.Bool.rawValue {
      return "dictionary.updateValue(\(name), forKey: \(constantName))"
    }
    return "if let value = \(name) { dictionary.updateValue(value, forKey: \(constantName) }"
  }

  func genDescriptionForPrimitiveArray(name: String, _ constantName: String) -> String {
    return "if let value = \(name) { dictionary.updateValue(value, forKey: \(constantName) }"
  }

  func genDescriptionForObject(name: String, _ constantName: String) -> String {
    return "if let value = \(name) { dictionary.updateValue(value.dictionaryRepresentation(), forKey: \(constantName) }"
  }

  func genDescriptionForObjectArray(name: String, _ constantName: String) -> String {
    return "if let value = \(name) { dictionary.updateValue(value.map { $0.dictionaryRepresentation() }, forKey: \(constantName) }"
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
    return "\tpublic var \(name): \(type)?\n"
  }

  /**
   Fetch the template for creating model.swift files.

   - returns: String containing the template.
   */
  func templateContent() -> String {
    let bundle = NSBundle.mainBundle()
    let path = bundle.pathForResource("BaseTemplate", ofType: "txt")
    do {
      let content = try String.init(contentsOfFile: path!)
      return content
    } catch {

    }
    return ""
  }

}
