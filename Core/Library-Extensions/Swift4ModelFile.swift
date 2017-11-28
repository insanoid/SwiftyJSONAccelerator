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
		case .valueType, .objectType:
			component.properties.append(genVariableDeclaration(property.name, property.type, false))
			component.mappingConstants.append(genEnumConstant(property.constantName, property.key))
		case .valueTypeArray, .objectTypeArray:
			component.properties.append(genVariableDeclaration(property.name, property.type, true))
			component.mappingConstants.append(genEnumConstant(property.constantName, property.key))
		case .emptyArray:
			component.properties.append(genVariableDeclaration(property.name, "Any", true))
			component.mappingConstants.append(genEnumConstant(property.constantName, property.key))
		case .nullType:
			// Currently we ignore null values.
			break
		}
	}

	func genPrimitiveVariableDeclaration(_ name: String, _ type: String) -> String {
		if type == VariableType.bool.rawValue {
			return "public var \(name): \(type) = false"
		}
		return "public var \(name): \(type)?"
	}
}
