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

class ModelGeneratorTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

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

  func defaultConfiguration(library: JSONMappingLibrary) -> ModelGenerationConfiguration {
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

  func testinitaliseModelFileFor() {
    let config = defaultConfiguration(.SwiftyJSON)
    let m = ModelGenerator.init(JSON.init([testJSON()]), config)
    expect(m.initaliseModelFileFor(.SwiftyJSON) is SwiftyJSONModelFile).to(equal(true))
    expect(m.initaliseModelFileFor(.SwiftyJSON) is ObjectMapperModelFile).to(equal(false))
  }

  func testSwiftyJSONForInvalidJSON() {
    let config = defaultConfiguration(.SwiftyJSON)
    let m = ModelGenerator.init(JSON.init(["hello!"]), config)
    let files = m.generate()
    expect(files.count).to(equal(0))
  }

  func testSwiftyJSONModelWithRootAsArray() {
    let config = defaultConfiguration(.SwiftyJSON)
    let m = ModelGenerator.init(JSON.init([testJSON()]), config)
    let files = m.generate()
    expect(files.count).to(equal(4))

    var objectKey = "ValueSix"
    objectKey.appendPrefix(config.prefix)
    expect(files[3].fileName).to(equal(objectKey))

    var subValueKey = "ValueSeven"
    subValueKey.appendPrefix(config.prefix)
    expect(files[1].fileName).to(equal(subValueKey))

    var objectArrayKey = "SubValueFive"
    objectArrayKey.appendPrefix(config.prefix)
    expect(files[2].fileName).to(equal(objectArrayKey))

    let baseModelFile = files.first
    var baseClass = config.baseClassName
    baseClass.appendPrefix(config.prefix)
    expect(baseModelFile!.fileName).to(equal(baseClass))
  }

  func testSwiftyJSONModel() {
    let config = defaultConfiguration(.SwiftyJSON)
    let m = ModelGenerator.init(testJSON(), config)
    let files = m.generate()

    expect(files.count).to(equal(4))

    var objectKey = "ValueSix"
    objectKey.appendPrefix(config.prefix)
    expect(files[3].fileName).to(equal(objectKey))

    var subValueKey = "ValueSeven"
    subValueKey.appendPrefix(config.prefix)
    expect(files[1].fileName).to(equal(subValueKey))

    var objectArrayKey = "SubValueFive"
    objectArrayKey.appendPrefix(config.prefix)
    expect(files[2].fileName).to(equal(objectArrayKey))

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

    expect(baseModelFile!.component.initialisers.count).to(equal(8))
    let initialisers = ["if let items = json[kACBaseClassValueSevenKey].array { valueSeven = items.map { ACValueSeven(json: $0) } }",
      "valueTwo = json[kACBaseClassValueTwoKey].int",
      "valueFour = json[kACBaseClassValueFourKey].float",
      "if let items = json[kACBaseClassValueFiveKey].array { valueFive = items.map { $0.String } }",
      "valueSix = ACValueSix(json: json[kACBaseClassValueSixKey])",
      "valueOne = json[kACBaseClassValueOneKey].string",
      "valueThree = json[kACBaseClassValueThreeKey].boolValue",
      "if let items = json[kACBaseClassValueEightKey].array { valueEight = items.map { $0.object } }"
    ]
    for initialiser in initialisers {
      expect(baseModelFile!.component.initialisers.contains(initialiser)).to(equal(true))
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
      "public var valueEight: [AnyObject]?"
    ]
    for declaration in declarations {
      expect(baseModelFile!.component.declarations.contains(declaration)).to(equal(true))
    }

    expect(baseModelFile!.component.description.count).to(equal(8))
    let descriptions = [
      "if let value = valueSeven { dictionary.updateValue(value.map { $0.dictionaryRepresentation() }, forKey: kACBaseClassValueSevenKey) }",
      "if let value = valueTwo { dictionary.updateValue(value, forKey: kACBaseClassValueTwoKey) }",
      "if let value = valueFour { dictionary.updateValue(value, forKey: kACBaseClassValueFourKey) }",
      "if let value = valueFive { dictionary.updateValue(value, forKey: kACBaseClassValueFiveKey) }",
      "if let value = valueSix { dictionary.updateValue(value.dictionaryRepresentation(), forKey: kACBaseClassValueSixKey) }",
      "if let value = valueOne { dictionary.updateValue(value, forKey: kACBaseClassValueOneKey) }",
      "dictionary.updateValue(valueThree, forKey: kACBaseClassValueThreeKey)",
      "if let value = valueEight { dictionary.updateValue(value, forKey: kACBaseClassValueEightKey) }"
    ]
    for description in descriptions {
      expect(baseModelFile!.component.description.contains(description)).to(equal(true))
    }

    expect(baseModelFile!.component.encoders.count).to(equal(8))
    let encoders = ["aCoder.encodeObject(valueSeven, forKey: kACBaseClassValueSevenKey)",
      "aCoder.encodeObject(valueTwo, forKey: kACBaseClassValueTwoKey)",
      "aCoder.encodeObject(valueFour, forKey: kACBaseClassValueFourKey)",
      "aCoder.encodeObject(valueFive, forKey: kACBaseClassValueFiveKey)",
      "aCoder.encodeObject(valueSix, forKey: kACBaseClassValueSixKey)",
      "aCoder.encodeObject(valueOne, forKey: kACBaseClassValueOneKey)",
      "aCoder.encodeBool(valueThree, forKey: kACBaseClassValueThreeKey)",
      "aCoder.encodeObject(valueEight, forKey: kACBaseClassValueEightKey)"]
    for encoder in encoders {
      expect(baseModelFile!.component.encoders.contains(encoder)).to(equal(true))
    }

    expect(baseModelFile!.component.decoders.count).to(equal(8))
    let decoders = [
      "self.valueSeven = aDecoder.decodeObjectForKey([kACBaseClassValueSevenKey]) as? ACValueSeven",
      "self.valueTwo = aDecoder.decodeObjectForKey(kACBaseClassValueTwoKey) as? Int",
      "self.valueFour = aDecoder.decodeObjectForKey(kACBaseClassValueFourKey) as? Float",
      "self.valueFive = aDecoder.decodeObjectForKey([kACBaseClassValueFiveKey]) as? String",
      "self.valueSix = aDecoder.decodeObjectForKey(kACBaseClassValueSixKey) as? ACValueSix",
      "self.valueOne = aDecoder.decodeObjectForKey(kACBaseClassValueOneKey) as? String",
      "self.valueThree = aDecoder.decodeBoolForKey(kACBaseClassValueThreeKey)",
      "self.valueEight = aDecoder.decodeObjectForKey([kACBaseClassValueEightKey]) as? AnyObject"
    ]
    for decoder in decoders {
      expect(baseModelFile!.component.decoders.contains(decoder)).to(equal(true))
    }

    for file in files {
      print(file.description())
    }

  }

}
