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

  /// Type of the the object, if a structure or a class.
  var type: ConstructType { get }

  /// Storage for various components of the model, it is used to store the intermediate data.
  var component: ModelComponent { get }

  /**
   Set the basic information for the given model file.

   - parameter fileName:      Name of the model file.
   - parameter configuration: Configuration for the model file.
   */
  mutating func setInfo(fileName: String, _ configuration: ModelGenerationConfiguration)

  /**
   Generate various required components for the given property.

   - parameter property: Property for which components are to be generated.
   */
  mutating func generateAndAddComponentsFor(property: PropertyComponent)

  /**
   Generate the final model.

   - returns: String representation for the model.
   */
  func generateModel() -> String

  /**
   Name of the module/model type.

   - returns: String representing the name of the model type.
   */
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

struct PropertyComponent {
  var name: String
  var type: String
  var constantName: String
  var key: String
  var propertyType: PropertyType

  init(_ name: String, _ type: String, _ constantName: String, _ key: String, _ propertyType: PropertyType) {
    self.name = name
    self.type = type
    self.constantName = constantName
    self.key = key
    self.propertyType = propertyType
  }
}

extension ModelFile {
  internal func description() {
    print(component.stringConstants.joinWithSeparator("\n"))
  }
}
