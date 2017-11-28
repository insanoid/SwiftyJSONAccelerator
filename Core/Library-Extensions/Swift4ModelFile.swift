//
//  Swift4Model.swift
//  SwiftyJSONAccelerator
//
//

import Foundation

/**
*  Provides support for SwiftyJSON library.
*/
struct Swift4ModelFile: ModelFile, DefaultModelFileComponent {

	var fileName: String
	var type: ConstructType
	var component: ModelComponent
	var sourceJSON: JSON
	var configuration: ModelGenerationConfiguration?

	// MARK: - Initialisers.
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
		return nil
	}

	func baseElementName() -> String? {
		return "Codable"
	}

	func mainBodyTemplateFileName() -> String {
		return "Swift4Template"
	}

	mutating func generateAndAddComponentsFor(_ property: PropertyComponent) {
		switch property.propertyType {
		case .valueType:
			component.stringConstants.append(genStringConstant(property.constantName, property.key))
			component.initialisers.append(genInitializerForVariable(property.name, property.type, property.constantName))
			component.declarations.append(genVariableDeclaration(property.name, property.type, false))
			component.description.append(genDescriptionForPrimitive(property.name, property.type, property.constantName))
			component.decoders.append(genDecoder(property.name, property.type, property.constantName, false))
			component.encoders.append(genEncoder(property.name, property.type, property.constantName))
		case .valueTypeArray:
			component.stringConstants.append(genStringConstant(property.constantName, property.key))
			component.initialisers.append(genInitializerForPrimitiveArray(property.name, property.type, property.constantName))
			component.declarations.append(genVariableDeclaration(property.name, property.type, true))
			component.description.append(genDescriptionForPrimitiveArray(property.name, property.constantName))
			component.decoders.append(genDecoder(property.name, property.type, property.constantName, true))
			component.encoders.append(genEncoder(property.name, property.type, property.constantName))
		case .objectType:
			component.stringConstants.append(genStringConstant(property.constantName, property.key))
			component.initialisers.append(genInitializerForObject(property.name, property.type, property.constantName))
			component.declarations.append(genVariableDeclaration(property.name, property.type, false))
			component.description.append(genDescriptionForObject(property.name, property.constantName))
			component.decoders.append(genDecoder(property.name, property.type, property.constantName, false))
			component.encoders.append(genEncoder(property.name, property.type, property.constantName))
		case .objectTypeArray:
			component.stringConstants.append(genStringConstant(property.constantName, property.key))
			component.initialisers.append(genInitializerForObjectArray(property.name, property.type, property.constantName))
			component.declarations.append(genVariableDeclaration(property.name, property.type, true))
			component.description.append(genDescriptionForObjectArray(property.name, property.constantName))
			component.decoders.append(genDecoder(property.name, property.type, property.constantName, true))
			component.encoders.append(genEncoder(property.name, property.type, property.constantName))
		case .emptyArray:
			component.stringConstants.append(genStringConstant(property.constantName, property.key))
			component.initialisers.append(genInitializerForPrimitiveArray(property.name, "object", property.constantName))
			component.declarations.append(genVariableDeclaration(property.name, "Any", true))
			component.description.append(genDescriptionForPrimitiveArray(property.name, property.constantName))
			component.decoders.append(genDecoder(property.name, "Any", property.constantName, true))
			component.encoders.append(genEncoder(property.name, "Any", property.constantName))
		case .nullType:
			// Currently we do not deal with null values.
			break
		}

		component.description = []
	}

	// MARK: - Customised methods for Swift 4
	// MARK: - Initialisers
	func genInitializerForVariable(_ name: String, _ type: String, _ constantName: String) -> String {
		var variableType = type
		variableType.lowerCaseFirst()
		if type == VariableType.bool.rawValue {
			return "\(name) = json[\(constantName)].\(variableType)Value"
		}
		return "\(name) = json[\(constantName)].\(variableType)"
	}

	func genInitializerForObject(_ name: String, _ type: String, _ constantName: String) -> String {
		return "\(name) = \(type)(json: json[\(constantName)])"
	}

	func genInitializerForObjectArray(_ name: String, _ type: String, _ constantName: String) -> String {
		return "if let items = json[\(constantName)].array { \(name) = items.map { \(type)(json: $0) } }"
	}

	func genInitializerForPrimitiveArray(_ name: String, _ type: String, _ constantName: String) -> String {
		var variableType = type
		variableType.lowerCaseFirst()
		if type == "object" {
			return "if let items = json[\(constantName)].array { \(name) = items.map { $0.\(variableType)} }"
		} else {
			return "if let items = json[\(constantName)].array { \(name) = items.map { $0.\(variableType)Value } }"
		}
	}

	func genPrimitiveVariableDeclaration(_ name: String, _ type: String) -> String {
		if type == VariableType.bool.rawValue {
			return "public var \(name): \(type) = false"
		}
		return "public var \(name): \(type)?"
	}
	
}
