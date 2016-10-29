//
//  JSONHelperTests.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 16/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import XCTest
import Nimble

/// Test basic corner cases for the JSONHelper.
class JSONHelperTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testIsValidJSONString() {
    var response = JSONHelper.isStringValidJSON("temp")
    expect(response.0).to(equal(false))
    expect(response.1).notTo(equal(nil))

    response = JSONHelper.isStringValidJSON("{\"key\":\"value\"}")
    expect(response.0).to(equal(true))
    expect(response.1).to(beNil())
  }

  func testConvertToJSON() {
    var response = JSONHelper.convertToObject("temp")
    expect(response.0).to(equal(false))
    expect(response.2).notTo(beNil())

    response = JSONHelper.convertToObject("{\"key\":\"value\"}")
    expect(response.0).to(equal(true))
    expect(response.2).to(beNil())

    response = JSONHelper.convertToObject(nil)
    expect(response.0).to(equal(false))
    expect(response.1).to(beNil())
  }

  func testPrettyJSON() {
    var response = JSONHelper.prettyJSON("temp")
    expect(response).to(beNil())
    response = JSONHelper.prettyJSON("{\"key\":\"value\"}")
    expect(response).to(equal("{\n  \"key\" : \"value\"\n}"))

    response = JSONHelper.prettyJSON(object: nil)
    expect(response).to(beNil())
    response = JSONHelper.prettyJSON(object:  JSONHelper.convertToObject("{\"key\": \"value\"}").1)
    expect(response).to(equal("{\n  \"key\" : \"value\"\n}"))

  }
}
