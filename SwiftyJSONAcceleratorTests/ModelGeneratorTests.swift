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
        return JSON.init(
                         ["value_one": "string value",
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
                         ])
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
        let config = defaultConfiguration(.libSwiftyJSON)
        let m = ModelGenerator.init(JSON.init([testJSON()]), config)
        expect(m.initialiseModelFileFor(.libSwiftyJSON) is SwiftyJSONModelFile).to(equal(true))
        expect(m.initialiseModelFileFor(.libSwiftyJSON) is ObjectMapperModelFile).to(equal(false))
        expect(m.initialiseModelFileFor(.libObjectMapper) is SwiftyJSONModelFile).to(equal(false))
        expect(m.initialiseModelFileFor(.libObjectMapper) is ObjectMapperModelFile).to(equal(true))
    }

    /**
   Test notifications to be generated for the given files.
   */
    func testNotifications() {
        let config = defaultConfiguration(.libSwiftyJSON)
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
    func testSwiftyJSONForInvalidJSON() {
        let config = defaultConfiguration(.libSwiftyJSON)
        let m = ModelGenerator.init(JSON.init(["hello!"]), config)
        let files = m.generate()
        expect(files.count).to(equal(0))
    }

    /**
   Generate files for JSON which is an array.
   */
    func testSwiftyJSONModelWithRootAsArray() {
        let config = defaultConfiguration(.libSwiftyJSON)
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
   Generate and test the files generated for SwiftyJSON value.
   */
    func testSwiftyJSONModel() {
        let config = defaultConfiguration(.libSwiftyJSON)
        let m = ModelGenerator.init(testJSON(), config)
        let files = m.generate()
        runCheckForBaseModel(files, config, runSwiftyJSONInitialiserCheckForBaseModel(_:))

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
        let config = defaultConfiguration(.libObjectMapper)
        let m = ModelGenerator.init(testJSON(), config)
        let files = m.generate()
        runCheckForBaseModel(files, config, runObjectMapperInitialiserCheckForBaseModel(_:))

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
        let config = defaultConfiguration(.libMarshal)
        let m = ModelGenerator.init(testJSON(), config)
        let files = m.generate()
        runCheckForBaseModel(files, config, runMarshalInitialiserCheckForBaseModel(_:))

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
            modelMappingLibrary: .libMarshal,
            supportNSCoding: true,
            isFinalRequired: true,
            isHeaderIncluded: true)
        let m = ModelGenerator.init(testJSON(), config)
        let files = m.generate()
        runCheckForBaseModel(files, config, runMarshalInitialiserCheckForBaseModel(_:))
        
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
    

    func runCheckForBaseModel(_ files: [ModelFile], _ config: ModelGenerationConfiguration, _ initialiserCheeck: ((ModelFile) -> Void)) {

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

        expect(baseModelFile!.component.stringConstants.count).to(equal(8))
        let stringConstants = [
            "static let valueSeven = \"value_seven\"",
            "static let valueTwo = \"value_two\"",
            "static let valueFour = \"value_four\"",
            "static let valueFive = \"value_five\"",
            "static let valueSix = \"value_six\"",
            "static let valueOne = \"value_one\"",
            "static let valueThree = \"value_three\"",
            "static let valueEight = \"value_eight\""
        ]
        for stringConstant in stringConstants {
            expect(baseModelFile!.component.stringConstants.contains(stringConstant)).to(equal(true))
        }

        expect(baseModelFile!.component.declarations.count).to(equal(8))
        let declarations = [
            "public var valueSeven: [ACValueSeven]?",
            "public var valueTwo: Int?",
            "public var valueFour: Float?",
            "public var valueFive: [String]?",
            "public var valueSix: ACValueSix?",
            "public var valueOne: String?",
            "public var valueThree: Bool? = false",
            "public var valueEight: [Any]?"
        ]
        for declaration in declarations {
            expect(baseModelFile!.component.declarations.contains(declaration)).to(equal(true))
        }

        expect(baseModelFile!.component.description.count).to(equal(8))
        let descriptions = [
            "if let value = valueSix { dictionary[SerializationKeys.valueSix] = value.dictionaryRepresentation() }",
            "if let value = valueFive { dictionary[SerializationKeys.valueFive] = value }",
            "if let value = valueTwo { dictionary[SerializationKeys.valueTwo] = value }",
            "dictionary[SerializationKeys.valueThree] = valueThree",
            "if let value = valueSeven { dictionary[SerializationKeys.valueSeven] = value.map { $0.dictionaryRepresentation() } }",
            "if let value = valueOne { dictionary[SerializationKeys.valueOne] = value }",
            "if let value = valueFour { dictionary[SerializationKeys.valueFour] = value }",
            "if let value = valueEight { dictionary[SerializationKeys.valueEight] = value }"
        ]
        for description in descriptions {
            expect(baseModelFile!.component.description.contains(description)).to(equal(true))
        }

        expect(baseModelFile!.component.encoders.count).to(equal(8))
        let encoders = [
            "aCoder.encode(valueSeven, forKey: SerializationKeys.valueSeven)",
            "aCoder.encode(valueTwo, forKey: SerializationKeys.valueTwo)",
            "aCoder.encode(valueFour, forKey: SerializationKeys.valueFour)",
            "aCoder.encode(valueFive, forKey: SerializationKeys.valueFive)",
            "aCoder.encode(valueSix, forKey: SerializationKeys.valueSix)",
            "aCoder.encode(valueOne, forKey: SerializationKeys.valueOne)",
            "aCoder.encode(valueThree, forKey: SerializationKeys.valueThree)",
            "aCoder.encode(valueEight, forKey: SerializationKeys.valueEight)"]
        for encoder in encoders {
            expect(baseModelFile!.component.encoders.contains(encoder)).to(equal(true))
        }

        expect(baseModelFile!.component.decoders.count).to(equal(8))
        let decoders = [
            "self.valueSeven = aDecoder.decodeObject(forKey: SerializationKeys.valueSeven) as? [ACValueSeven]",
            "self.valueTwo = aDecoder.decodeObject(forKey: SerializationKeys.valueTwo) as? Int",
            "self.valueFour = aDecoder.decodeObject(forKey: SerializationKeys.valueFour) as? Float",
            "self.valueFive = aDecoder.decodeObject(forKey: SerializationKeys.valueFive) as? [String]",
            "self.valueSix = aDecoder.decodeObject(forKey: SerializationKeys.valueSix) as? ACValueSix",
            "self.valueOne = aDecoder.decodeObject(forKey: SerializationKeys.valueOne) as? String",
            "self.valueThree = aDecoder.decodeBool(forKey: SerializationKeys.valueThree)",
            "self.valueEight = aDecoder.decodeObject(forKey: SerializationKeys.valueEight) as? [Any]"
        ]
        for decoder in decoders {
            expect(baseModelFile!.component.decoders.contains(decoder)).to(equal(true))
        }
    }

    func runSwiftyJSONInitialiserCheckForBaseModel(_ baseModelFile: ModelFile) {
        expect(baseModelFile.component.initialisers.count).to(equal(8))
        let initialisers = [
            "if let items = json[SerializationKeys.valueSeven].array { valueSeven = items.map { ACValueSeven(json: $0) } }",
            "valueTwo = json[SerializationKeys.valueTwo].int",
            "valueFour = json[SerializationKeys.valueFour].float",
            "if let items = json[SerializationKeys.valueFive].array { valueFive = items.map { $0.stringValue } }",
            "valueSix = ACValueSix(json: json[SerializationKeys.valueSix])",
            "valueOne = json[SerializationKeys.valueOne].string",
            "valueThree = json[SerializationKeys.valueThree].boolValue",
            "if let items = json[SerializationKeys.valueEight].array { valueEight = items.map { $0.object} }"
        ]
        for initialiser in initialisers {
            expect(baseModelFile.component.initialisers.contains(initialiser)).to(equal(true))
        }
    }

    func runObjectMapperInitialiserCheckForBaseModel(_ baseModelFile: ModelFile) {
        expect(baseModelFile.component.initialisers.count).to(equal(8))
        let initialisers = [
            "valueSeven <- map[SerializationKeys.valueSeven]",
            "valueTwo <- map[SerializationKeys.valueTwo]",
            "valueFour <- map[SerializationKeys.valueFour]",
            "valueFive <- map[SerializationKeys.valueFive]",
            "valueSix <- map[SerializationKeys.valueSix]",
            "valueEight <- map[SerializationKeys.valueEight]",
            "valueOne <- map[SerializationKeys.valueOne]",
            "valueThree <- map[SerializationKeys.valueThree]"
        ]
        for initialiser in initialisers {
            expect(baseModelFile.component.initialisers.contains(initialiser)).to(equal(true))
        }
    }

    func runMarshalInitialiserCheckForBaseModel(_ baseModelFile: ModelFile) {
        expect(baseModelFile.component.initialisers.count).to(equal(8))
        let initialisers = [
            "valueSeven = try? object.value(for: SerializationKeys.valueSeven)",
            "valueTwo = try? object.value(for: SerializationKeys.valueTwo)",
            "valueFour = try? object.value(for: SerializationKeys.valueFour)",
            "valueFive = try? object.value(for: SerializationKeys.valueFive)",
            "valueSix = try? object.value(for: SerializationKeys.valueSix)",
            "valueOne = try? object.value(for: SerializationKeys.valueOne)",
            "valueThree = try? object.value(for: SerializationKeys.valueThree)",
            "valueEight = try? object.value(for: SerializationKeys.valueEight)"
        ]
        for initialiser in initialisers {
            expect(baseModelFile.component.initialisers.contains(initialiser)).to(equal(true))
        }
    }

}
