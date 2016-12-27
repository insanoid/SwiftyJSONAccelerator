//
//  StringTests.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 06/07/2016.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import XCTest
import Nimble

/// Additional tests foe String extensions.
class StringTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testFirst() {
    let str1 = "demo"
    expect(str1.first).to(equal("d"))

    let str2 = ""
    expect(str2.first).to(equal(""))
  }

  func testCases() {
    var str1 = "demo"
    str1.uppercaseFirst()
    expect(str1).to(equal("Demo"))
    str1.uppercaseFirst()
    expect(str1).to(equal("Demo"))
    str1.lowerCaseFirst()
    expect(str1).to(equal("demo"))
    str1.lowerCaseFirst()
    expect(str1).to(equal("demo"))
  }

  func testReplacement() {
    var str1 = "demo_of-the%app_works-well"
    str1.replaceOccurrencesOfStringsWithString(["_", "-", "%"], " ")
    expect(str1).to(equal("demo of the app works well"))
  }

  func testPrefix() {
    var str1 = "Demo"
    str1.appendPrefix("AC")
    expect(str1).to(equal("ACDemo"))
    str1.appendPrefix("")
    expect(str1).to(equal("ACDemo"))
    str1.appendPrefix(nil)
    expect(str1).to(equal("ACDemo"))
  }

}
