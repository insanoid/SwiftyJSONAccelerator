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
        ]
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

  func testSwiftyJSONFailure() {
    let config = defaultConfiguration(.SwiftyJSON)
    let m = ModelGenerator.init(JSON.init(["hello!"]), config)
    let files = m.generate()
    expect(files.count).to(equal(0))
  }

  func testSwiftyJSONModelWithRootArray() {
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

    expect(baseModelFile!.component.stringConstants.count).to(equal(7))
    expect(baseModelFile!.component.stringConstants.contains("private let kACBaseClassValueTwoKey: String = \"value_two\"")).to(equal(true))
    expect(baseModelFile!.component.stringConstants.contains("private let kACBaseClassValueOneKey: String = \"value_one\"")).to(equal(true))
    expect(baseModelFile!.component.stringConstants.contains("private let kACBaseClassValueFourKey: String = \"value_four\"")).to(equal(true))
    expect(baseModelFile!.component.stringConstants.contains("private let kACBaseClassValueFiveKey: String = \"value_five\"")).to(equal(true))
    expect(baseModelFile!.component.stringConstants.contains("private let kACBaseClassValueSixKey: String = \"value_six\"")).to(equal(true))
    expect(baseModelFile!.component.stringConstants.contains("private let kACBaseClassValueThreeKey: String = \"value_three\"")).to(equal(true))
    expect(baseModelFile!.component.stringConstants.contains("private let kACBaseClassValueSevenKey: String = \"value_seven\"")).to(equal(true))

    expect(baseModelFile!.component.declarations.count).to(equal(7))
    expect(baseModelFile!.component.declarations.contains("public var valueOne: String?")).to(equal(true))
    expect(baseModelFile!.component.declarations.contains("public var valueFour: Float?")).to(equal(true))
    expect(baseModelFile!.component.declarations.contains("public var valueFive: [String]?")).to(equal(true))
    expect(baseModelFile!.component.declarations.contains("public var valueSix: ACValueSix?")).to(equal(true))
    expect(baseModelFile!.component.declarations.contains("public var valueThree: Bool = false")).to(equal(true))
    expect(baseModelFile!.component.declarations.contains("public var valueTwo: Int?")).to(equal(true))
    expect(baseModelFile!.component.declarations.contains("public var valueSeven: [ACValueSeven]?")).to(equal(true))

    expect(baseModelFile!.component.initialisers.count).to(equal(7))
    expect(baseModelFile!.component.initialisers.contains("valueTwo = json[kACBaseClassValueTwoKey].int")).to(equal(true))
    expect(baseModelFile!.component.initialisers.contains("valueOne = json[kACBaseClassValueOneKey].string")).to(equal(true))
    expect(baseModelFile!.component.initialisers.contains("valueFour = json[kACBaseClassValueFourKey].float")).to(equal(true))
    expect(baseModelFile!.component.initialisers.contains("valueThree = json[kACBaseClassValueThreeKey].boolValue")).to(equal(true))
    expect(baseModelFile!.component.initialisers.contains("if let items = json[kACBaseClassValueFiveKey].array { valueFive = items.map { $0.String } }")).to(equal(true))
    expect(baseModelFile!.component.initialisers.contains("valueSix = ACValueSix(json: json[kACBaseClassValueSixKey])")).to(equal(true))
    expect(baseModelFile!.component.initialisers.contains("if let items = json[kACBaseClassValueSevenKey].array { valueSeven = items.map { ACValueSeven(json: $0) } }")).to(equal(true))

    expect(baseModelFile!.component.declarations.count).to(equal(7))
    expect(baseModelFile!.component.declarations.contains("public var valueOne: String?")).to(equal(true))
    expect(baseModelFile!.component.declarations.contains("public var valueFour: Float?")).to(equal(true))
    expect(baseModelFile!.component.declarations.contains("public var valueFive: [String]?")).to(equal(true))
    expect(baseModelFile!.component.declarations.contains("public var valueSix: ACValueSix?")).to(equal(true))
    expect(baseModelFile!.component.declarations.contains("public var valueThree: Bool = false")).to(equal(true))
    expect(baseModelFile!.component.declarations.contains("public var valueTwo: Int?")).to(equal(true))

    expect(baseModelFile!.component.description.count).to(equal(7))
    expect(baseModelFile!.component.description.contains("if let value = valueOne { dictionary.updateValue(value, forKey: kACBaseClassValueOneKey) }")).to(equal(true))
    expect(baseModelFile!.component.description.contains("if let value = valueTwo { dictionary.updateValue(value, forKey: kACBaseClassValueTwoKey) }")).to(equal(true))
    expect(baseModelFile!.component.description.contains("dictionary.updateValue(valueThree, forKey: kACBaseClassValueThreeKey)")).to(equal(true))
    expect(baseModelFile!.component.description.contains("if let value = valueFour { dictionary.updateValue(value, forKey: kACBaseClassValueFourKey) }")).to(equal(true))
    expect(baseModelFile!.component.description.contains("if let value = valueFive { dictionary.updateValue(value, forKey: kACBaseClassValueFiveKey) }")).to(equal(true))
    expect(baseModelFile!.component.description.contains("if let value = valueSix { dictionary.updateValue(value.dictionaryRepresentation(), forKey: kACBaseClassValueSixKey) }")).to(equal(true))
    expect(baseModelFile!.component.description.contains("if let value = valueSeven { dictionary.updateValue(value.map { $0.dictionaryRepresentation() }, forKey: kACBaseClassValueSevenKey) }")).to(equal(true))

    for file in files {
      print(file.description())
    }
  }

}
