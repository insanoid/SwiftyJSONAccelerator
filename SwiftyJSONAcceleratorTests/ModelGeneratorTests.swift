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
import SwiftyJSON

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
        "value_dont_show": nil,
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
      constructType: .StructType,
      modelMappingLibrary: library,
      supportNSCoding: true)
  }

  /**
   Test model file initialisation test.
   */
  func testinitaliseModelFileFor() {
    let config = defaultConfiguration(.SwiftyJSON)
    let m = ModelGenerator.init(JSON.init([testJSON()]), config)
    expect(m.initaliseModelFileFor(.SwiftyJSON) is SwiftyJSONModelFile).to(equal(true))
    expect(m.initaliseModelFileFor(.SwiftyJSON) is ObjectMapperModelFile).to(equal(false))
    expect(m.initaliseModelFileFor(.ObjectMapper) is SwiftyJSONModelFile).to(equal(false))
    expect(m.initaliseModelFileFor(.ObjectMapper) is ObjectMapperModelFile).to(equal(true))
  }

  /**
   Test notifications to be generated for the given files.
   */
  func testNotifications() {
    let config = defaultConfiguration(.SwiftyJSON)
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
    let config = defaultConfiguration(.SwiftyJSON)
    let m = ModelGenerator.init(JSON.init(["hello!"]), config)
    let files = m.generate()
    expect(files.count).to(equal(0))
  }

  /**
   Generate files for JSON which is an array.
   */
  func testSwiftyJSONModelWithRootAsArray() {
    let config = defaultConfiguration(.SwiftyJSON)
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
    let config = defaultConfiguration(.SwiftyJSON)
    let m = ModelGenerator.init(testJSON(), config)
    let files = m.generate()
    runCheckForBaseModel(files, config, runSwiftyJSONInitialiserCheckForBaseModel(_:))

    for m in files {
      let content = FileGenerator.generateFileContentWith(m, configuration: config)
      let name = m.fileName
      let path = "/Users/karthikeyaudupa/Desktop/tmp/sj/"
      expect(FileGenerator.writeToFileWith(name, content: content, path: path)).to(equal(true))
    }

  }

  /**
   Generate and test the files generated for ObjectMapper value.
   */
  func testObjectMapperModel() {
    let config = defaultConfiguration(.ObjectMapper)
    let m = ModelGenerator.init(testJSON(), config)
    let files = m.generate()
    runCheckForBaseModel(files, config, runObjectMapperInitialiserCheckForBaseModel(_:))

    for m in files {
      let content = FileGenerator.generateFileContentWith(m, configuration: config)
      let name = m.fileName
      let path = "/Users/karthikeyaudupa/Desktop/tmp/om/"
      expect(FileGenerator.writeToFileWith(name, content: content, path: path)).to(equal(true))
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
      "private let kACBaseClassValueSevenKey: String = \"value_seven\"",
      "private let kACBaseClassValueTwoKey: String = \"value_two\"",
      "private let kACBaseClassValueFourKey: String = \"value_four\"",
      "private let kACBaseClassValueFiveKey: String = \"value_five\"",
      "private let kACBaseClassValueSixKey: String = \"value_six\"",
      "private let kACBaseClassValueOneKey: String = \"value_one\"",
      "private let kACBaseClassValueThreeKey: String = \"value_three\"",
      "private let kACBaseClassValueEightKey: String = \"value_eight\""
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
      "public var valueThree: Bool = false",
      "public var valueEight: [Any]?"
    ]
    for declaration in declarations {
      expect(baseModelFile!.component.declarations.contains(declaration)).to(equal(true))
    }

    expect(baseModelFile!.component.description.count).to(equal(8))
    let descriptions = [
        "if let value = valueSix { dictionary[kACBaseClassValueSixKey] = value.dictionaryRepresentation() }",
        "if let value = valueFive { dictionary[kACBaseClassValueFiveKey] = value }",
        "if let value = valueTwo { dictionary[kACBaseClassValueTwoKey] = value }",
        "dictionary[kACBaseClassValueThreeKey] = valueThree",
        "if let value = valueSeven { dictionary[kACBaseClassValueSevenKey] = value.map { $0.dictionaryRepresentation() } }",
        "if let value = valueOne { dictionary[kACBaseClassValueOneKey] = value }",
        "if let value = valueFour { dictionary[kACBaseClassValueFourKey] = value }",
        "if let value = valueEight { dictionary[kACBaseClassValueEightKey] = value }"
    ]
    for description in descriptions {
      expect(baseModelFile!.component.description.contains(description)).to(equal(true))
    }

    expect(baseModelFile!.component.encoders.count).to(equal(8))
    let encoders = [
      "aCoder.encode(valueSeven, forKey: kACBaseClassValueSevenKey)",
      "aCoder.encode(valueTwo, forKey: kACBaseClassValueTwoKey)",
      "aCoder.encode(valueFour, forKey: kACBaseClassValueFourKey)",
      "aCoder.encode(valueFive, forKey: kACBaseClassValueFiveKey)",
      "aCoder.encode(valueSix, forKey: kACBaseClassValueSixKey)",
      "aCoder.encode(valueOne, forKey: kACBaseClassValueOneKey)",
      "aCoder.encode(valueThree, forKey: kACBaseClassValueThreeKey)",
      "aCoder.encode(valueEight, forKey: kACBaseClassValueEightKey)"]
    for encoder in encoders {
      expect(baseModelFile!.component.encoders.contains(encoder)).to(equal(true))
    }

    expect(baseModelFile!.component.decoders.count).to(equal(8))
    let decoders = [
      "self.valueSeven = aDecoder.decodeObject(forKey: kACBaseClassValueSevenKey) as? [ACValueSeven]",
      "self.valueTwo = aDecoder.decodeObject(forKey: kACBaseClassValueTwoKey) as? Int",
      "self.valueFour = aDecoder.decodeObject(forKey: kACBaseClassValueFourKey) as? Float",
      "self.valueFive = aDecoder.decodeObject(forKey: kACBaseClassValueFiveKey) as? [String]",
      "self.valueSix = aDecoder.decodeObject(forKey: kACBaseClassValueSixKey) as? ACValueSix",
      "self.valueOne = aDecoder.decodeObject(forKey: kACBaseClassValueOneKey) as? String",
      "self.valueThree = aDecoder.decodeBool(forKey: kACBaseClassValueThreeKey)",
      "self.valueEight = aDecoder.decodeObject(forKey: kACBaseClassValueEightKey) as? [Any]"
    ]
    for decoder in decoders {
      expect(baseModelFile!.component.decoders.contains(decoder)).to(equal(true))
    }
  }

  func runSwiftyJSONInitialiserCheckForBaseModel(_ baseModelFile: ModelFile) {
    expect(baseModelFile.component.initialisers.count).to(equal(8))
    let initialisers = [
      "if let items = json[kACBaseClassValueSevenKey].array { valueSeven = items.map { ACValueSeven(json: $0) } }",
      "valueTwo = json[kACBaseClassValueTwoKey].int",
      "valueFour = json[kACBaseClassValueFourKey].float",
      "if let items = json[kACBaseClassValueFiveKey].array { valueFive = items.map { $0.stringValue } }",
      "valueSix = ACValueSix(json: json[kACBaseClassValueSixKey])",
      "valueOne = json[kACBaseClassValueOneKey].string",
      "valueThree = json[kACBaseClassValueThreeKey].boolValue",
      "if let items = json[kACBaseClassValueEightKey].array { valueEight = items.map { $0.object} }"
    ]
    for initialiser in initialisers {
      expect(baseModelFile.component.initialisers.contains(initialiser)).to(equal(true))
    }
  }

  func runObjectMapperInitialiserCheckForBaseModel(_ baseModelFile: ModelFile) {
    expect(baseModelFile.component.initialisers.count).to(equal(8))
    let initialisers = [
      "valueSeven <- map[kACBaseClassValueSevenKey]",
      "valueTwo <- map[kACBaseClassValueTwoKey]",
      "valueFour <- map[kACBaseClassValueFourKey]",
      "valueFive <- map[kACBaseClassValueFiveKey]",
      "valueSix <- map[kACBaseClassValueSixKey]",
      "valueEight <- map[kACBaseClassValueEightKey]",
      "valueOne <- map[kACBaseClassValueOneKey]",
      "valueThree <- map[kACBaseClassValueThreeKey]"
    ]
    for initialiser in initialisers {
      expect(baseModelFile.component.initialisers.contains(initialiser)).to(equal(true))
    }
  }
}
