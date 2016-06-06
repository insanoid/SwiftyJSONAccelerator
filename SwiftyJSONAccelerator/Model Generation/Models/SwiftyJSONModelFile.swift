//
//  SwiftyJSONModel.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 02/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

struct SwiftyJSONModelFile: ModelFile {

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
    var finalString = ""
    finalString.appendContentsOf(component.stringConstants.joinWithSeparator("\n\t"))
    return finalString

  }
  func moduleName() -> String {
    return "SwiftyJSON"
  }

  mutating func addBasicInfo(name: String, _ type: String, _ constantName: String) {

  }

  // MARK: - Generator methods.
  mutating func addStringConstant(constantName: String, _ value: String) {
    component.stringConstants.append(genStringConstant(constantName, value))
  }

  mutating func addEncoder(name: String, _ type: String, _ constantName: String) {
    component.encoders.append(genEncoder(name, type, constantName))
  }
}
