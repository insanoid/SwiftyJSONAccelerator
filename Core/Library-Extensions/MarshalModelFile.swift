//
//  MarshalModelFile.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 04/12/2016.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

struct MarshalModelFile: ModelFile, DefaultModelFileComponent {

    /// Filename for the model.
    var fileName: String
    var type: ConstructType
    var component: ModelComponent
    var sourceJSON: JSON
    var configuration: ModelGenerationConfiguration?

    init() {
        self.fileName = ""
        type = ConstructType.structType
        component = ModelComponent.init()
        sourceJSON = JSON.init([])
    }

    mutating func setInfo(_ fileName: String, _ configuration: ModelGenerationConfiguration) {
        self.fileName = fileName
        type = configuration.constructType
        self.configuration = configuration
    }

    func moduleName() -> String? {
        return "Marshal"
    }

    func baseElementName() -> String? {
        return "Unmarshaling"
    }

    func mainBodyTemplateFileName() -> String {
        return "MarshalTemplate"
    }

    mutating func generateAndAddComponentsFor(_ property: PropertyComponent) {
        switch property.propertyType {

        case .valueType:
            component.properties.append(genVariableDeclaration(property.name, property.type, false))
            component.dictionaryDescriptions.append(genDescriptionForPrimitive(property.name, property.type, property.constantName))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, false))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
            generateCommonComponentsFor(property)
        case .valueTypeArray:
            component.dictionaryDescriptions.append(genDescriptionForPrimitiveArray(property.name, property.constantName))
            component.properties.append(genVariableDeclaration(property.name, property.type, true))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, true))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
            generateCommonComponentsFor(property)
        case .objectType:
            component.dictionaryDescriptions.append(genDescriptionForObject(property.name, property.constantName))
            component.properties.append(genVariableDeclaration(property.name, property.type, false))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, false))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
            generateCommonComponentsFor(property)
        case .objectTypeArray:
            component.properties.append(genVariableDeclaration(property.name, property.type, true))
            component.dictionaryDescriptions.append(genDescriptionForObjectArray(property.name, property.constantName))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, true))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
            generateCommonComponentsFor(property)

        case .emptyArray:
            component.properties.append(genVariableDeclaration(property.name, "Any", true))
            component.dictionaryDescriptions.append(genDescriptionForPrimitiveArray(property.name, property.constantName))
            component.decoders.append(genDecoder(property.name, "Any", property.constantName, true))
            component.encoders.append(genEncoder(property.name, "Any", property.constantName))
            generateCommonComponentsFor(property)
        case .nullType: break
            // Currently we do not deal with null values.

        }
    }

    fileprivate mutating func generateCommonComponentsFor(_ property: PropertyComponent) {
        component.mappingConstants.append(genStringConstant(property.constantName, property.key))
        component.initialisers.append(genInitializerForVariable(property.name, property.constantName))
    }

    // MARK: - Customised methods for ObjectMapper
    // MARK: - Initialisers
    func genInitializerForVariable(_ name: String, _ constantName: String) -> String {
        return "\(name) = try? object.value(for: \(constantName))"
    }

}
