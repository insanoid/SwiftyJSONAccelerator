//
//  SwiftyJSONModel.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 02/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

struct SwiftyJSONModelFile: ModelFile, DefaultModelFileComponent {

  var fileName: String
  var type: ConstructType
  var component: ModelComponent

  // MARK: - Initialisers.
  init() {
    self.fileName = ""
    type = ConstructType.StructType
    component = ModelComponent.init()
  }

  mutating func setInfo(fileName: String, _ configuration: ModelGenerationConfiguration) {
    self.fileName = fileName
    type = configuration.constructType
  }

  func generateModel() -> String {
    var finalString = ""
    finalString.appendContentsOf(component.stringConstants.joinWithSeparator("\n\t"))
    return finalString

  }
  func moduleName() -> String {
    return "SwiftyJSON"
  }

  // MARK: - Add Information
  // MARK: - Add Basic Information
  mutating func addBasicInfo(name: String, _ type: String, _ constantName: String) {
    component.initialisers.append(genInitializerForVariable(name, type, constantName))
    component.declarations.append(genVariableDeclaration(name, type, false))
    component.description.append(genDescriptionForPrimitive(name, type, constantName))
  }

  mutating func addObjectInfo(name: String, _ type: String, _ constantName: String) {
    component.initialisers.append(genInitializerForObject(name, type, constantName))
    component.declarations.append(genVariableDeclaration(name, type, false))
    component.description.append(genDescriptionForObject(name, constantName))
  }

  mutating func addObjectArrayInfo(name: String, _ type: String, _ constantName: String) {
    component.initialisers.append(genInitializerForObjectArray(name, type, constantName))
    component.declarations.append(genVariableDeclaration(name, type, true))
    component.description.append(genDescriptionForObjectArray(name, constantName))
  }

  mutating func addPrimitiveArrayInfo(name: String, _ type: String, _ constantName: String) {
    component.initialisers.append(genInitializerForPrimitiveArray(name, type, constantName))
    component.declarations.append(genVariableDeclaration(name, type, true))
    component.description.append(genDescriptionForPrimitiveArray(name, constantName))
  }

  // MARK: - Generator methods.
  mutating func addStringConstant(constantName: String, _ value: String) {
    component.stringConstants.append(genStringConstant(constantName, value))
  }

  mutating func addEncoder(name: String, _ type: String, _ constantName: String) {
    component.encoders.append(genEncoder(name, type, constantName))
  }

  // MARK: - Customised methods for SWiftyJSON
  // MARK: - Initialisers
  func genInitializerForVariable(name: String, _ type: String, _ constantName: String) -> String {
    var variableType = type
    variableType.lowerCaseFirst()
    if type == VariableType.Bool.rawValue {
      return "\(name) = json[\(constantName)].\(variableType)Value"
    }
    return "\(name) = json[\(constantName)].\(variableType)"
  }

  func genInitializerForObject(name: String, _ type: String, _ constantName: String) -> String {
    return "\(name) = \(type)(json: json[\(constantName)])"
  }

  func genInitializerForObjectArray(name: String, _ type: String, _ constantName: String) -> String {
    return "if let items = json[\(constantName)].array { \(name) = items.map { \(type)(json: $0) } }"
  }

  func genInitializerForPrimitiveArray(name: String, _ type: String, _ constantName: String) -> String {
    var variableType = type
    variableType.lowerCaseFirst()
    return "if let items = json[\(constantName)].array { \(name) = items.map { $0.\(type) } }"
  }

  // MARK: - Decoders
  func addDecoder(name: String, _ type: String, _ constantName: String) {

  }
  func addInitialiser(name: String, _ type: String, _ constantName: String) {

  }
  func addDescription(name: String, _ type: String, _ constantName: String) {

  }
  func addDeclaration(name: String, _ type: String, _ constantName: String) {

  }

  func addEmptyArray(name: String, _ type: String, _ constantName: String) {

  }
  func addEmptyArrayInfo(name: String, _ type: String, _ constantName: String) {

  }

}
