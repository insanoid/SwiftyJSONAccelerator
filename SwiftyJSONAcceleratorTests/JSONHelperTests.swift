//
//  JSONHelperTests.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 16/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import XCTest
import Nimble

class JSONHelperTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testIsValidJSONString() {
    var response = JSONHelper.isStringValidJSON("aaa")
    expect(response.0).to(equal(false))
    expect(response.1).notTo(equal(nil))

    response = JSONHelper.isStringValidJSON("{\"aaa\":\"some\"}")
    expect(response.0).to(equal(true))
    expect(response.1).to(beNil())
  }
}
