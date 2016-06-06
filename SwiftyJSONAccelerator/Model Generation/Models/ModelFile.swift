//
//  ModelFile.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 01/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

/**
 *  A protocol defining the structure of the model file.
 */
protocol ModelFile {

  /// Filename for the model.
  var fileName: String { get set }
  var type: ConstructType { get }
  var component: ModelComponent { get }

  mutating func setInfo(fileName: String, _ configuration: ModelGenerationConfiguration)

  mutating func addStringConstant(constantName: String, _ value: String)
  mutating func addEncoder(name: String, _ type: String, _ constantName: String)

  func addDecoder(name: String, _ type: String, _ constantName: String)
  func addInitialiser(name: String, _ type: String, _ constantName: String)
  func addDescription(name: String, _ type: String, _ constantName: String)
  func addDeclaration(name: String, _ type: String, _ constantName: String)

  func addBasicInfo(name: String, _ type: String, _ constantName: String)
  func addPrimitiveArrayInfo(name: String, _ type: String, _ constantName: String)
  func addObjectArrayInfo(name: String, _ type: String, _ constantName: String)
  func addEmptyArray(name: String, _ type: String, _ constantName: String)
  func addEmptyArrayInfo(name: String, _ type: String, _ constantName: String)

  func generateModel() -> String
  func moduleName() -> String

}

struct ModelComponent {
  var declarations: [String]
  var stringConstants: [String]
  var initialisers: [String]
  var encoders: [String]
  var decoders: [String]
  var description: [String]

  init() {
    declarations = []
    stringConstants = []
    initialisers = []
    encoders = []
    decoders = []
    description = []
  }
}
