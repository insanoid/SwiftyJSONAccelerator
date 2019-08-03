//
//  StringTests.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 06/07/2016.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation
import XCTest

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
        XCTAssert(str1.first == "d")

        let str2 = ""
        XCTAssertNil(str2.first)
    }

    func testCases() {
        var str1 = "demo"
        str1.uppercaseFirst()
        XCTAssert(str1 == "Demo")
        str1.uppercaseFirst()
        XCTAssert(str1 == "Demo")
        str1.lowercaseFirst()
        XCTAssert(str1 == "demo")
        str1.lowercaseFirst()
        XCTAssert(str1 == "demo")
    }

    func testReplacement() {
        var str1 = "demo_of-the%app_works-well"
        str1.replaceOccurrencesOfStringsWithString(["_", "-", "%"], " ")
        XCTAssert(str1 == "demo of the app works well")
    }

    func testPrefix() {
        var str1 = "Demo"
        str1.appendPrefix("AC")
        XCTAssert(str1 == "ACDemo")
        str1.appendPrefix("")
        XCTAssert(str1 == "ACDemo")
        str1.appendPrefix(nil)
        XCTAssert(str1 == "ACDemo")
    }

    func testTrimChars() {
        var str1 = " De mo      "
        str1.trim()
        XCTAssert(str1 == "De mo")
    }

    func testCharAtIndex() {
        let str1 = "0123456789\n1234567890"
        XCTAssert(str1.characterRowAndLineAt(position: 1).character == "0")
        XCTAssert(str1.characterRowAndLineAt(position: 12).character == "1")
        XCTAssert(str1.characterRowAndLineAt(position: 12).line == 2)
        XCTAssert(str1.characterRowAndLineAt(position: 12).column == 1)
        XCTAssert("".characterRowAndLineAt(position: 12).character.isEmpty)
        XCTAssert(str1.characterRowAndLineAt(position: 11).character == "\n")
    }
}
