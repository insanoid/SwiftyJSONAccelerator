//
//  ModalGenerator.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 25/07/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Model generator responsible for creation of models based on the JSON, needs to be initialised with all properties before proceeding.
public struct ModelGenerator {
    /// Configuration for generation of the model.
    var configuration: ModelGenerationConfiguration
    /// JSON content that has to be processed.
    var baseContent: JSON

    /// Initialise the structure with the JSON and configuration
    ///
    /// - Parameters:
    ///   - baseContent: Base content JSON that has to be used to generate the model.
    ///   - configuration: Configuration to generate the the model.
    init(_ baseContent: JSON, _ configuration: ModelGenerationConfiguration) {
        self.baseContent = baseContent
        self.configuration = configuration
    }

    /// Generate the models for the structure based on the set configuration and content.
    ///
    /// - Returns: An array of files that were generated.
    func generate() -> [ModelFile] {
        return generateModelForJSON(baseContent, configuration.baseClassName, true)
    }

    /**
     Generate a set model files for the given JSON object.

     - parameter object:           Object that has to be parsed.
     - parameter defaultClassName: Default Classname for the object.
     - parameter isTopLevelObject: Is the current object the root object in the JSON.

     - returns: Model files for the current object and sub objects.
     */
    func generateModelForJSON(_ object: JSON, _ defaultClassName: String, _ isTopLevelObject: Bool) -> [ModelFile] {
        let className = NameGenerator.fixClassName(defaultClassName, configuration.prefix, isTopLevelObject)
        var modelFiles: [ModelFile] = []

        // Incase the object was NOT a dictionary. (this would only happen in case of the top level
        // object, since internal objects are handled within the function and do not pass an array here)
        if let rootObject = object.array, let firstObject = rootObject.first {
            let subClassType = firstObject.detailedValueType()
            // If the type of the first item is an object then make it the base class and generate
            // stuff. However, currently it does not make a base file to handle the array.
            if subClassType == .object {
                return generateModelForJSON(JSONHelper.reduce(rootObject), defaultClassName, isTopLevelObject)
            }
            return []
        }

        if let rootObject = object.dictionary {
            // A model file to store the current model.
            var currentModel = SwiftJSONModelFile()
            currentModel.setInfo(className, configuration)
            currentModel.sourceJSON = object

            for (key, value) in rootObject {
                /// basic information, name, type and the constant to store the key.
                let variableName = NameGenerator.fixVariableName(key)
                let variableType = value.detailedValueType()
                let stringConstantName = NameGenerator.variableKey(className, variableName)

                switch variableType {
                case .array:
                    if value.arrayValue.isEmpty {
                        currentModel.generateAndAddComponentsFor(PropertyComponent(variableName, VariableType.array.rawValue, stringConstantName, key, .emptyArray))
                    } else {
                        let subClassType = value.arrayValue.first!.detailedValueType()
                        if subClassType == .object {
                            let models = generateModelForJSON(JSONHelper.reduce(value.arrayValue), variableName, false)
                            modelFiles += models
                            let model = models.first
                            let classname = model?.fileName
                            currentModel.generateAndAddComponentsFor(PropertyComponent(variableName, classname!, stringConstantName, key, .objectTypeArray))
                        } else {
                            currentModel.generateAndAddComponentsFor(PropertyComponent(variableName, subClassType.rawValue, stringConstantName, key, .valueTypeArray))
                        }
                    }
                case .object:
                    let models = generateModelForJSON(value, variableName, false)
                    let model = models.first
                    let typeName = model?.fileName
                    currentModel.generateAndAddComponentsFor(PropertyComponent(variableName, typeName!, stringConstantName, key, .objectType))
                    modelFiles += models
                case .null:
                    currentModel.generateAndAddComponentsFor(PropertyComponent(variableName, VariableType.null.rawValue, stringConstantName, key, .nullType))
                default:
                    currentModel.generateAndAddComponentsFor(PropertyComponent(variableName, variableType.rawValue, stringConstantName, key, .valueType))
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
        let notification = NSUserNotification()
        notification.title = NSLocalizedString("SwiftyJSONAccelerator", comment: "")
        if !modelFiles.isEmpty {
            let firstModel = (modelFiles.first)!
            notification.subtitle = String(format: NSLocalizedString("Completed - %@.swift", comment: ""), firstModel.fileName)
        } else {
            notification.subtitle = NSLocalizedString("No files were generated, cannot model arrays inside arrays.", comment: "")
        }
        return notification
    }
}
