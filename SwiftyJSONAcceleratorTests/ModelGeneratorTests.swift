//
//  SJModelGeneratorTests.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 01/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation
import XCTest
import Nimble

fileprivate extension JSONMappingLibrary {

	static func testJSON() -> [String: Any] {
		return ["value_one": "string value",
		 "value_two": 3,
		 "value_three": true,
		 "value_four": 3.4,
		 "value_dont_show": JSON.null,
		 "value_five": ["string", "random_stuff"],
		 "value_six": ["sub_value": "value", "sub_value_second": false],
		 "value_seven": [
			[
				"sub_value_third": 4.5,
				"double_value": Double.init(5.3),
				"sub_value_four": "value",
				"internal": "renamed_value",
				"sub_value_five": ["two_level_down": "value"]
			]
			],
		 "value_eight": []
		]
	}

	var initializers: [String] {
		switch self {
		case .marshal:
			return [
				"valueSeven = try? object.value(for: SerializationKeys.valueSeven)",
				"valueTwo = try? object.value(for: SerializationKeys.valueTwo)",
				"valueFour = try? object.value(for: SerializationKeys.valueFour)",
				"valueFive = try? object.value(for: SerializationKeys.valueFive)",
				"valueSix = try? object.value(for: SerializationKeys.valueSix)",
				"valueOne = try? object.value(for: SerializationKeys.valueOne)",
				"valueThree = try? object.value(for: SerializationKeys.valueThree)",
				"valueEight = try? object.value(for: SerializationKeys.valueEight)"
			]
		case .objectMapper:
			return [
				"valueSeven <- map[SerializationKeys.valueSeven]",
				"valueTwo <- map[SerializationKeys.valueTwo]",
				"valueFour <- map[SerializationKeys.valueFour]",
				"valueFive <- map[SerializationKeys.valueFive]",
				"valueSix <- map[SerializationKeys.valueSix]",
				"valueEight <- map[SerializationKeys.valueEight]",
				"valueOne <- map[SerializationKeys.valueOne]",
				"valueThree <- map[SerializationKeys.valueThree]"
			]
		case .swiftyJSON:
			return [
				"if let items = json[SerializationKeys.valueSeven].array { valueSeven = items.map { ACValueSeven(json: $0) } }",
				"valueTwo = json[SerializationKeys.valueTwo].int",
				"valueFour = json[SerializationKeys.valueFour].float",
				"if let items = json[SerializationKeys.valueFive].array { valueFive = items.map { $0.stringValue } }",
				"valueSix = ACValueSix(json: json[SerializationKeys.valueSix])",
				"valueOne = json[SerializationKeys.valueOne].string",
				"valueThree = json[SerializationKeys.valueThree].boolValue",
				"if let items = json[SerializationKeys.valueEight].array { valueEight = items.map { $0.object} }"
			]
		case .swift4:
			return []
		}
	}

	var decoders: [String] {
		switch self {
		case .marshal, .objectMapper, .swiftyJSON:
			return [
				"self.valueSeven = aDecoder.decodeObject(forKey: SerializationKeys.valueSeven) as? [ACValueSeven]",
				"self.valueTwo = aDecoder.decodeObject(forKey: SerializationKeys.valueTwo) as? Int",
				"self.valueFour = aDecoder.decodeObject(forKey: SerializationKeys.valueFour) as? Float",
				"self.valueFive = aDecoder.decodeObject(forKey: SerializationKeys.valueFive) as? [String]",
				"self.valueSix = aDecoder.decodeObject(forKey: SerializationKeys.valueSix) as? ACValueSix",
				"self.valueOne = aDecoder.decodeObject(forKey: SerializationKeys.valueOne) as? String",
				"self.valueThree = aDecoder.decodeBool(forKey: SerializationKeys.valueThree)",
				"self.valueEight = aDecoder.decodeObject(forKey: SerializationKeys.valueEight) as? [Any]"
			]
		case .swift4:
			return []
		}
	}

	var encoders: [String] {
		switch self {
		case .marshal, .objectMapper, .swiftyJSON:
			return [
				"aCoder.encode(valueSeven, forKey: SerializationKeys.valueSeven)",
				"aCoder.encode(valueTwo, forKey: SerializationKeys.valueTwo)",
				"aCoder.encode(valueFour, forKey: SerializationKeys.valueFour)",
				"aCoder.encode(valueFive, forKey: SerializationKeys.valueFive)",
				"aCoder.encode(valueSix, forKey: SerializationKeys.valueSix)",
				"aCoder.encode(valueOne, forKey: SerializationKeys.valueOne)",
				"aCoder.encode(valueThree, forKey: SerializationKeys.valueThree)",
				"aCoder.encode(valueEight, forKey: SerializationKeys.valueEight)"
			]
		case .swift4:
			return []
		}
	}

	var properties: [String] {
		switch self {
		case .marshal, .objectMapper, .swiftyJSON:
			return [
				"public var valueSeven: [ACValueSeven]?",
				"public var valueTwo: Int?",
				"public var valueFour: Float?",
				"public var valueFive: [String]?",
				"public var valueSix: ACValueSix?",
				"public var valueOne: String?",
				"public var valueThree: Bool? = false",
				"public var valueEight: [Any]?"
			]
		case .swift4:
			return [
				"public var valueSeven: [ACValueSeven]?",
				"public var valueTwo: Int?",
				"public var valueFour: Float?",
				"public var valueFive: [String]?",
				"public var valueSix: ACValueSix?",
				"public var valueOne: String?",
				"public var valueThree: Bool = false",
				"public var valueEight: [Any]?"
			]
		}
	}

	var dictionaryDescriptions: [String] {
		switch self {
		case .marshal, .objectMapper, .swiftyJSON:
			return [
				"if let value = valueSix { dictionary[SerializationKeys.valueSix] = value.dictionaryRepresentation() }",
				"if let value = valueFive { dictionary[SerializationKeys.valueFive] = value }",
				"if let value = valueTwo { dictionary[SerializationKeys.valueTwo] = value }",
				"dictionary[SerializationKeys.valueThree] = valueThree",
				"if let value = valueSeven { dictionary[SerializationKeys.valueSeven] = value.map { $0.dictionaryRepresentation() } }",
				"if let value = valueOne { dictionary[SerializationKeys.valueOne] = value }",
				"if let value = valueFour { dictionary[SerializationKeys.valueFour] = value }",
				"if let value = valueEight { dictionary[SerializationKeys.valueEight] = value }"
			]
		case .swift4:
			return []
		}
	}

	var mapping: [String] {
		switch self {
		case .marshal, .objectMapper, .swiftyJSON:
			return  [
				"static let valueSeven = \"value_seven\"",
				"static let valueTwo = \"value_two\"",
				"static let valueFour = \"value_four\"",
				"static let valueFive = \"value_five\"",
				"static let valueSix = \"value_six\"",
				"static let valueOne = \"value_one\"",
				"static let valueThree = \"value_three\"",
				"static let valueEight = \"value_eight\""
			]
		case .swift4:
			return [
				"case valueSeven = \"value_seven\"",
				"case valueTwo = \"value_two\"",
				"case valueFour = \"value_four\"",
				"case valueFive = \"value_five\"",
				"case valueSix = \"value_six\"",
				"case valueOne = \"value_one\"",
				"case valueThree = \"value_three\"",
				"case valueEight = \"value_eight\""
			]
		}
	}
}

fileprivate extension ModelGenerationConfiguration {

	func testData(for path: KeyPath<ModelComponent,[String]>) -> [String] {
		switch path {
		case \ModelComponent.initialisers:
			return self.modelMappingLibrary.initializers
		case \ModelComponent.decoders:
			return self.modelMappingLibrary.decoders
		case \ModelComponent.encoders:
			return self.modelMappingLibrary.encoders
		case \ModelComponent.properties:
			return self.modelMappingLibrary.properties
		case \ModelComponent.dictionaryDescriptions:
			return self.modelMappingLibrary.dictionaryDescriptions
		case \ModelComponent.mappingConstants:
			return self.modelMappingLibrary.mapping
		default:
			return []
		}
	}
}


/// Test cases for the model Generator.
class ModelGeneratorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
    }

    override func tearDown() {
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
        super.tearDown()
    }

    /**
   Generate a sample JSON class with all possible scenarioes.

   - returns: A valid JSON.
   */
    func testJSON() -> JSON {
        return JSON.init(JSONMappingLibrary.testJSON())
    }

    /**
   Default configuration for the tests.

   - parameter library: Type of library to use.

   - returns: Default configuration file.
   */
    func defaultConfiguration(_ library: JSONMappingLibrary) -> ModelGenerationConfiguration {
        return ModelGenerationConfiguration.init(
                                                 filePath: "/tmp/",
                                                 baseClassName: "BaseClass",
                                                 authorName: "Jane Smith",
                                                 companyName: "Acme Co.",
                                                 prefix: "AC",
                                                 constructType: .structType,
                                                 modelMappingLibrary: library,
                                                 supportNSCoding: true,
                                                 isFinalRequired: true,
                                                 isHeaderIncluded: true)
    }

    /**
   Test model file initialisation test.
   */
    func testinitialiseModelFileFor() {
        let config = defaultConfiguration(.swiftyJSON)
        let m = ModelGenerator.init(JSON.init([testJSON()]), config)
        expect(m.initialiseModelFileFor(.swiftyJSON) is SwiftyJSONModelFile).to(equal(true))
        expect(m.initialiseModelFileFor(.swiftyJSON) is ObjectMapperModelFile).to(equal(false))
        expect(m.initialiseModelFileFor(.objectMapper) is SwiftyJSONModelFile).to(equal(false))
        expect(m.initialiseModelFileFor(.objectMapper) is ObjectMapperModelFile).to(equal(true))
    }

    /**
   Test notifications to be generated for the given files.
   */
    func testNotifications() {
        let config = defaultConfiguration(.swiftyJSON)
        let m = ModelGenerator.init(JSON.init([testJSON()]), config)
        let files = m.generate()
        let errorNotification = m.generateNotificationFor([])
        expect(errorNotification.title).to(equal("SwiftyJSONAccelerator"))
        expect(errorNotification.subtitle).to(equal("No files were generated, cannot model arrays inside arrays."))
        let correctNotification = m.generateNotificationFor(files)
        expect(correctNotification.title).to(equal("SwiftyJSONAccelerator"))
        expect(correctNotification.subtitle).to(equal("Completed - ACBaseClass.swift"))

    }

    /**
   Test for invalid JSON.
   */
    func testSwift4ForInvalidJSON() {
        let config = defaultConfiguration(.swift4)
        let m = ModelGenerator.init(JSON.init(["hello!"]), config)
        let files = m.generate()
        expect(files.count).to(equal(0))
    }

    /**
   Generate files for JSON which is an array.
   */
    func testSwift4ModelWithRootAsArray() {
        let config = defaultConfiguration(.swift4)
        let m = ModelGenerator.init(JSON.init([testJSON()]), config)
        let files = m.generate()
        expect(files.count).to(equal(4))

        var objectKey = "ValueSix"
        objectKey.appendPrefix(config.prefix)
        expect(files[1].fileName).to(equal(objectKey))

        var subValueKey = "ValueSeven"
        subValueKey.appendPrefix(config.prefix)
        expect(files[2].fileName).to(equal(subValueKey))

        var objectArrayKey = "SubValueFive"
        objectArrayKey.appendPrefix(config.prefix)
        expect(files[3].fileName).to(equal(objectArrayKey))

        let baseModelFile = files.first
        var baseClass = config.baseClassName
        baseClass.appendPrefix(config.prefix)
        expect(baseModelFile!.fileName).to(equal(baseClass))
    }

	/**
	Generate and test the files generated for Swift4 value.
	*/
	func testSwift4Model() {
		let config = defaultConfiguration(.swift4)
		let m = ModelGenerator.init(testJSON(), config)
		let files = m.generate()
		runChecksForBaseModel(files, config)

		for m in files {
			let content = FileGenerator.generateFileContentWith(m, configuration: config)
			let name = m.fileName
			let path = "/tmp/sj/"
			do {
				try FileGenerator.writeToFileWith(name, content: content, path: path)
			} catch {
				assertionFailure("File generation Failed")
			}
		}

	}


    /**
   Generate and test the files generated for SwiftyJSON value.
   */
    func testSwiftyJSONModel() {
        let config = defaultConfiguration(.swiftyJSON)
        let m = ModelGenerator.init(testJSON(), config)
        let files = m.generate()
        runChecksForBaseModel(files, config)

        for m in files {
            let content = FileGenerator.generateFileContentWith(m, configuration: config)
            let name = m.fileName
            let path = "/tmp/sj/"
            do {
                try FileGenerator.writeToFileWith(name, content: content, path: path)
            } catch {
                assertionFailure("File generation Failed")
            }
        }

    }

    /**
   Generate and test the files generated for ObjectMapper value.
   */
    func testObjectMapperModel() {
        let config = defaultConfiguration(.objectMapper)
        let m = ModelGenerator.init(testJSON(), config)
        let files = m.generate()
        runChecksForBaseModel(files, config)

        for m in files {
            let content = FileGenerator.generateFileContentWith(m, configuration: config)
            let name = m.fileName
            let path = "/tmp/om/"
            do {
                try FileGenerator.writeToFileWith(name, content: content, path: path)
            } catch {
                assertionFailure("File generation Failed")
            }
        }
    }

    /**
     Generate and test the files generated for Marshal value.
     */
    func testMarshalModel() {
        let config = defaultConfiguration(.marshal)
        let m = ModelGenerator.init(testJSON(), config)
        let files = m.generate()
        runChecksForBaseModel(files, config)

        for m in files {
            let content = FileGenerator.generateFileContentWith(m, configuration: config)
            expect(content.contains("public required init(object: MarshaledObject)")).to(equal(false))
            expect(content.contains("public init(object: MarshaledObject)")).to(equal(true))
            expect(content.contains("public struct")).to(equal(true))
            let name = m.fileName
            let path = config.filePath
            do {
                try FileGenerator.writeToFileWith(name, content: content, path: path)
            } catch {
                assertionFailure("File generation Failed")
            }
        }
    }
    
    func testMarshalModelAsClass() {
        let config = ModelGenerationConfiguration.init(
            filePath: "/tmp/ml",
            baseClassName: "BaseClass",
            authorName: "Jane Smith",
            companyName: "Acme Co.",
            prefix: "AC",
            constructType: .classType,
            modelMappingLibrary: .marshal,
            supportNSCoding: true,
            isFinalRequired: true,
            isHeaderIncluded: true)
        let m = ModelGenerator.init(testJSON(), config)
        let files = m.generate()
        runChecksForBaseModel(files, config)
        
        for m in files {
            let content = FileGenerator.generateFileContentWith(m, configuration: config)
            expect(content.contains("public required init(object: MarshaledObject)")).to(equal(true))
            expect(content.contains("public init(object: MarshaledObject)")).to(equal(false))
            expect(content.contains("public final class")).to(equal(true))
            let name = m.fileName
            let path = config.filePath
            do {
                try FileGenerator.writeToFileWith(name, content: content, path: path)
            } catch {
                assertionFailure("File generation Failed")
            }
        }
    }


	func runChecksForBaseModel(_ files: [ModelFile], _ config: ModelGenerationConfiguration) {

		let baseModelFile = runCheckForFiles(files, config)

		let path: WritableKeyPath = \ModelComponent.initialisers
		path
		let checkingKeypaths = [
			\ModelComponent.initialisers,
			\ModelComponent.mappingConstants,
			\ModelComponent.properties,
			\ModelComponent.dictionaryDescriptions,
			\ModelComponent.encoders,
			\ModelComponent.decoders
		]

		for path in checkingKeypaths {
			print("Checking \(path.hashValue)")
			runCheckForModelKeypathEquality(baseModelFile, path)
		}
    }

	func runCheckForFiles(_ files: [ModelFile], _ config: ModelGenerationConfiguration) -> ModelFile {
		expect(files.count).to(equal(4))

		var objectKey = "ValueSix"
		objectKey.appendPrefix(config.prefix)
		expect(files[1].fileName).to(equal(objectKey))

		var subValueKey = "ValueSeven"
		subValueKey.appendPrefix(config.prefix)
		expect(files[2].fileName).to(equal(subValueKey))

		var objectArrayKey = "SubValueFive"
		objectArrayKey.appendPrefix(config.prefix)
		expect(files[3].fileName).to(equal(objectArrayKey))

		let baseModelFile = files.first!
		var baseClass = config.baseClassName
		baseClass.appendPrefix(config.prefix)
		expect(baseModelFile.fileName).to(equal(baseClass))

		return baseModelFile
	}

	func runCheckForModelKeypathEquality(_ baseModelFile: ModelFile,
	                                     _ componentKeyPath: KeyPath<ModelComponent, [String]>) {

		let dataComponent = baseModelFile.configuration?.testData(for: componentKeyPath)
		let modelComponent = baseModelFile.component[keyPath: componentKeyPath]
		let data = dataComponent ?? []
		expect(modelComponent.count).to(equal(data.count))
		for component in data {
			let expectation = expect(modelComponent.contains(component))
			if !expectation.to(equal(true)) {
				print(modelComponent)
				print(component)
			}

		}
	}
}
