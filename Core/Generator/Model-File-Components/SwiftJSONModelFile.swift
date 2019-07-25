
//
//  SwiftJSONModelFile.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 25/07/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Provides support for SwiftyJSON library.
struct SwiftJSONModelFile: ModelFile {
    var fileName: String
    var type: ConstructType
    var component: ModelComponent
    var sourceJSON: JSON
    var configuration: ModelGenerationConfiguration?

    // MARK: - Initialisers.

    init() {
        fileName = ""
        type = ConstructType.structType
        component = ModelComponent()
        sourceJSON = JSON([])
    }

    mutating func setInfo(_ fileName: String, _ configuration: ModelGenerationConfiguration) {
        self.fileName = fileName
        type = configuration.constructType
        self.configuration = configuration
    }

    func mainBodyTemplateFileName() -> String {
        return "BaseTemplate"
    }

    mutating func generateAndAddComponentsFor(_ property: PropertyComponent) {
        let isOptional = configuration!.variablesOptional
        let isArray = property.propertyType == .valueTypeArray || property.propertyType == .objectTypeArray
        let isObject = property.propertyType == .objectType || property.propertyType == .objectTypeArray
        let type = property.propertyType == .emptyArray ? "Any" : property.type

        switch property.propertyType {
        case .valueType, .valueTypeArray, .objectType, .objectTypeArray, .emptyArray:
            component.stringConstants.append(genStringConstant(property.constantName, property.key))
            component.declarations.append(genVariableDeclaration(property.name, type, isArray, isOptional))
            component.initialisers.append(genInitializerForVariable(name: property.name, type: property.type, constantName: property.constantName, isOptional: isOptional, isArray: isArray, isObject: isObject))
        case .nullType:
            // Currently we do not deal with null values.
            break
        }
    }

    /// Format the incoming string is in the case format.
    ///
    /// - Parameters:
    ///   - constantName: Constant value to represent the variable.
    ///   - value: Value for the key that is used in the JSON.
    /// - Returns: Returns `case <constant> = "value"`.
    func genStringConstant(_ constantName: String, _ value: String) -> String {
        let component = constantName.components(separatedBy: ".")
        return "case \(component.last!) = \"\(value)\""
    }

    /// Generate the variable declaration string
    ///
    /// - Parameters:
    ///   - name: variable name to be used
    ///   - type: variable type to use
    ///   - isArray: Is the value an object
    ///   - isOptional: Is optional variable kind
    /// - Returns: A string to use as the declration
    func genVariableDeclaration(_ name: String, _ type: String, _ isArray: Bool, _ isOptional: Bool) -> String {
        var _type = type
        if isArray {
            _type = "[\(type)]"
        }
        return genPrimitiveVariableDeclaration(name, _type, isOptional)
    }

    /// Generate the variable declaration string
    ///
    /// - Parameters:
    ///   - name: variable name to be used
    ///   - type: variable type to use
    ///   - isArray: Is the value an object
    /// - Returns: A string to use as the declration
    func genPrimitiveVariableDeclaration(_ name: String, _ type: String, _ isOptional: Bool) -> String {
        if isOptional {
            return "var \(name): \(type)?"
        }
        return "var \(name): \(type)"
    }

    func genInitializerForVariable(name: String, type: String, constantName: String, isOptional: Bool, isArray: Bool, isObject _: Bool) -> String {
        var variableType = type
        if isArray {
            variableType = "[\(type)]"
        }
        let component = constantName.components(separatedBy: ".")
        let decodeMethod = isOptional ? "decodeIfPresent" : "decode"
        return "\(name) = try container.\(decodeMethod)(\(variableType).self, forKey: .\(component.last!))"
    }
}
