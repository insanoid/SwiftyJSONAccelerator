//
//  ObjectMapperModel.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 02/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

struct ObjectMapperModelFile: ModelFile, DefaultModelFileComponent {

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

    func moduleName() -> String {
        return "ObjectMapper"
    }

    func baseElementName() -> String? {
        return "Mappable"
    }

    func mainBodyTemplateFileName() -> String {
        return "ObjectMapperTemplate"
    }

    mutating func generateAndAddComponentsFor(_ property: PropertyComponent) {
        switch property.propertyType {

        case .valueType:
            component.declarations.append(genVariableDeclaration(property.name, property.type, false))
            component.description.append(genDescriptionForPrimitive(property.name, property.type, property.constantName))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, false))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
            generateCommonComponentsFor(property)
        case .valueTypeArray:
            component.description.append(genDescriptionForPrimitiveArray(property.name, property.constantName))
            component.declarations.append(genVariableDeclaration(property.name, property.type, true))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, true))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
            generateCommonComponentsFor(property)
        case .objectType:
            component.description.append(genDescriptionForObject(property.name, property.constantName))
            component.declarations.append(genVariableDeclaration(property.name, property.type, false))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, false))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
            generateCommonComponentsFor(property)
        case .objectTypeArray:
            component.declarations.append(genVariableDeclaration(property.name, property.type, true))
            component.description.append(genDescriptionForObjectArray(property.name, property.constantName))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, true))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
            generateCommonComponentsFor(property)

        case .emptyArray:
            component.declarations.append(genVariableDeclaration(property.name, "Any", true))
            component.description.append(genDescriptionForPrimitiveArray(property.name, property.constantName))
            component.decoders.append(genDecoder(property.name, "Any", property.constantName, true))
            component.encoders.append(genEncoder(property.name, "Any", property.constantName))
            generateCommonComponentsFor(property)
        case .nullType: break
            // Currently we do not deal with null values.

        }
    }

    fileprivate mutating func generateCommonComponentsFor(_ property: PropertyComponent) {
        component.stringConstants.append(genStringConstant(property.constantName, property.key))
        component.initialisers.append(genInitializerForVariable(property.name, property.constantName))
    }

    // MARK: - Customised methods for ObjectMapper
    // MARK: - Initialisers
    func genInitializerForVariable(_ name: String, _ constantName: String) -> String {
        return "\(name) <- map[\(constantName)]"
    }

}
