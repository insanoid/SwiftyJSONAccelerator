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
    return JSON.init(["value_one": "string value", "value_two": 3, "value_three": true, "value_four": 3.4, "value_five": ["string", "random_stuff"], "value_six": ["sub_value": "value", "sub_value_second": false]])
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

  func testSwiftyJSONModel() {
    let config = defaultConfiguration(.SwiftyJSON)
    let m = ModelGenerator.init(testJSON(), config)
    let files = m.generate()

    expect(files.count).to(equal(2))

    var objectKey = "ValueSix"
    objectKey.appendPrefix(config.prefix)
    expect(files.last?.fileName).to(equal(objectKey))

    let baseModelFile = files.first
    var baseClass = config.baseClassName
    baseClass.appendPrefix(config.prefix)
    expect(baseModelFile!.fileName).to(equal(baseClass))
    expect(baseModelFile!.component.initialisers.count).to(equal(6))

    /*
     internal let kACBaseClassValueTwoKey: String = "value_two"
     internal let kACBaseClassValueOneKey: String = "value_one"
     internal let kACBaseClassValueFourKey: String = "value_four"
     internal let kACBaseClassValueFiveKey: String = "value_five"
     internal let kACBaseClassValueSixKey: String = "value_six"
     internal let kACBaseClassValueThreeKey: String = "value_three"
     */

    for file in files {
      print(file.description())
    }
  }

}
