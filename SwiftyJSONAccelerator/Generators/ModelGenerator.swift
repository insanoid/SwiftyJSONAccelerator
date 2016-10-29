//
//  SJModelGenerator.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 20/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Model generator responsible for creation of models based on the JSON, needs to be initialised
/// with all properties before proceeding.
public struct ModelGenerator {

  /// Configuration for generation of the model.
  var configuration: ModelGenerationConfiguration
  /// JSON content that has to be processed.
  var baseContent: JSON

  /**
   Initialise the structure with the JSON and configuration

   - parameter baseContent:   Base content JSON that has to be used to generate the model.
   - parameter configuration: Configuration to generate the the model.
   */
  init(_ baseContent: JSON, _ configuration: ModelGenerationConfiguration) {
    self.baseContent = baseContent
    self.configuration = configuration
  }

  /**
   Generate the models for the structure based on the set configuration and content.
   - returns: An array of files that were generated.
   */
  func generate() -> [ModelFile] {
    return self.generateModelForJSON(baseContent, configuration.baseClassName, true)
  }

  /**
   Generate a set model files for the given JSON object.

   - parameter object:           Object that has to be parsed.
   - parameter defaultClassName: Default Classname for the object.
   - parameter isTopLevelObject: Is the current object the root object in the JSON.

   - returns: Model files for the current object and sub objects.
   */
  func generateModelForJSON(_ object: JSON, _ defaultClassName: String, _ isTopLevelObject: Bool) -> [ModelFile] {

    let className = NameGenerator.fixClassName(defaultClassName, self.configuration.prefix, isTopLevelObject)
    var modelFiles: [ModelFile] = []

    // Incase the object was NOT a dictionary. (this would only happen in case of the top level
    // object, since internal objects are handled within the function and do not pass an array here)
    if let rootObject = object.array, let firstObject = rootObject.first {
      let subClassType = firstObject.detailedValueType()
      // If the type of the first item is an object then make it the base class and generate
      // stuff. However, currently it does not make a base file to handle the array.
      if subClassType == .Object {
        return self.generateModelForJSON(JSONHelper.reduce(rootObject), defaultClassName, isTopLevelObject)
      }
      return []

    }

    if let rootObject = object.dictionary {
      // A model file to store the current model.
      var currentModel = self.initaliseModelFileFor(configuration.modelMappingLibrary)
      currentModel.setInfo(className, configuration)

      for (key, value) in rootObject {
        /// basic information, name, type and the constant to store the key.
        let variableName = NameGenerator.fixVariableName(key)
        let variableType = value.detailedValueType()
        let stringConstantName = NameGenerator.variableKey(className, variableName)

        switch variableType {
        case .Array:
          if value.arrayValue.count <= 0 {
            currentModel.generateAndAddComponentsFor(PropertyComponent.init(variableName, VariableType.Array.rawValue, stringConstantName, key, .EmptyArray))
          } else {
            let subClassType = value.arrayValue.first!.detailedValueType()
            if subClassType == .Object {
              let models = generateModelForJSON(JSONHelper.reduce(value.arrayValue), variableName, false)
              modelFiles = modelFiles + models
              let model = models.first
              let classname = model?.fileName
              currentModel.generateAndAddComponentsFor(PropertyComponent.init(variableName, classname!, stringConstantName, key, .ObjectTypeArray))
            } else {
              currentModel.generateAndAddComponentsFor(PropertyComponent.init(variableName, subClassType.rawValue, stringConstantName, key, .ValueTypeArray))
            }
          }
        case .Object:
          let models = generateModelForJSON(value, variableName, false)
          let model = models.first
          let typeName = model?.fileName
          currentModel.generateAndAddComponentsFor(PropertyComponent.init(variableName, typeName!, stringConstantName, key, .ObjectType))
          modelFiles = modelFiles + models
        case .Null:
          currentModel.generateAndAddComponentsFor(PropertyComponent.init(variableName, VariableType.Null.rawValue, stringConstantName, key, .NullType))
          break
        default:
          currentModel.generateAndAddComponentsFor(PropertyComponent.init(variableName, variableType.rawValue, stringConstantName, key, .ValueType))
        }

      }

      modelFiles = [currentModel] + modelFiles
    }

    // at the end we return the collection of files.
    return modelFiles
  }

  /**
   Generates the notification message for the model files returned.

   - parameter modelFiles: Array of model files that were generated.

   - returns: Notification tht was generated.
   */
  func generateNotificationFor(_ modelFiles: [ModelFile]) -> NSUserNotification {
    let notification: NSUserNotification = NSUserNotification()
    notification.title = NSLocalizedString("SwiftyJSONAccelerator", comment: "")
    if modelFiles.count > 0 {
      let firstModel = (modelFiles.first)!
      notification.subtitle = String.init(format: NSLocalizedString("Completed - %@.swift", comment: ""), firstModel.fileName)
    } else {
      notification.subtitle = NSLocalizedString("No files were generated, cannot model arrays inside arrays.", comment: "")
    }
    return notification
  }

  /**
   Initialise a ModelFile of a certain Library type based on the requirement.

   - parameter modelMappingLibrary: Library the generated modal has to support.

   - returns: A new model file of the required type.
   */
  func initaliseModelFileFor(_ modelMappingLibrary: JSONMappingLibrary) -> ModelFile {
    switch modelMappingLibrary {
    case .ObjectMapper:
      return ObjectMapperModelFile()
    case .SwiftyJSON:
      return SwiftyJSONModelFile()
    }
  }

}
