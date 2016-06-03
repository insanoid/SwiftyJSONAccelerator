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

  func testFailureCases() {
    let config: ModelGenerationConfiguration = ModelGenerationConfiguration.init(
      filePath: "/tmp/",
      baseClassName: "Demo",
      authorName: "karthik",
      companyName: "Sample",
      prefix: "PR",
      constructType: .StructType,
      modelMappingLibrary: .SwiftyJSON,
      supportNSCoding: true)

    let m = ModelGenerator.init(JSON.init(arrayLiteral: ["A": "Test", "b": ["A", "x"]]), config)
    print(m.generate())
  }

}
