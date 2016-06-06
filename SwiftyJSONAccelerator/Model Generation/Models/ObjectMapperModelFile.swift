//
//  ObjectMapperModel.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 02/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

struct ObjectMapperModelFile: ModelFile {

  /// Filename for the model.
  var fileName: String
  var type: ConstructType
  var component: ModelComponent

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
    return ""

  }
  func moduleName() -> String {
    return "ObjectMapper"
  }

  // MARK: - Generator methods.
  mutating func addStringConstant(constantName: String, _ value: String) {
    component.stringConstants.append(self.genStringConstant(constantName, value))
  }

  mutating func addEncoder(name: String, _ type: String, _ constantName: String) {
    component.encoders.append(genEncoder(name, type, constantName))
  }

  mutating func addBasicInfo(name: String, _ type: String, _ constantName: String) {
    component.initialisers.append("\(name) <- map[\(constantName)]")
  }

}
