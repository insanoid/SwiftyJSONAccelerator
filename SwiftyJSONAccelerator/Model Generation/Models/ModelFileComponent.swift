//
//  ModelFileComponent.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 02/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

extension ModelFile {

  func addDecoder(name: String, _ type: String, _ constantName: String) {

  }
  func addInitialiser(name: String, _ type: String, _ constantName: String) {

  }
  func addDescription(name: String, _ type: String, _ constantName: String) {

  }
  func addDeclaration(name: String, _ type: String, _ constantName: String) {

  }

  func addBasicInfo(name: String, _ type: String, _ constantName: String) {

  }
  func addPrimitiveArrayInfo(name: String, _ type: String, _ constantName: String) {

  }
  func addObjectArrayInfo(name: String, _ type: String, _ constantName: String) {

  }
  func addEmptyArray(name: String, _ type: String, _ constantName: String) {

  }
  func addEmptyArrayInfo(name: String, _ type: String, _ constantName: String) {

  }

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

  func descriptionForObjectVariableArray(name: String, _ type: String, _ constantName: String) -> String {
    if type == VariableType.Bool.rawValue {
      return "dictionary.updateValue(\(name), forKey: \(constantName))"
    }
    return "if let value = \(name) { dictionary.updateValue(value, forKey: \(constantName) }"
  }

}
