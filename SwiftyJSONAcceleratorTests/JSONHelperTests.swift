//
//  JSONHelperTests.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 16/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import SwiftyJSON
import XCTest

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
        XCTAssert(response.isValid == false)
        XCTAssert(response.parsedObject == nil)

        response = JSONHelper.isStringValidJSON("{\"key\":\"value\"}")
        XCTAssert(response.isValid == true)
        XCTAssert(response.error == nil)
        XCTAssert(response.parsedObject!.isEqual(["key": "value"]))
    }

    func testConvertToJSON() {
        var response = JSONHelper.convertToObject("temp")
        XCTAssert(response.isValid == false)
        XCTAssert(response.error != nil)

        response = JSONHelper.convertToObject("{\"key\":\"value\"}")
        XCTAssert(response.isValid == true)
        XCTAssert(response.error == nil)
        XCTAssert(response.parsedObject!.isEqual(["key": "value"]))

        response = JSONHelper.convertToObject(nil)
        XCTAssert(response.isValid == false)
        XCTAssert(response.parsedObject == nil)
    }

    func testPrettyJSON() {
        var response = JSONHelper.prettyJSON("temp")
        XCTAssert(response == nil)
        response = JSONHelper.prettyJSON("{\"key\":\"value\"}")
        XCTAssert(response == "{\n  \"key\" : \"value\"\n}")

        response = JSONHelper.prettyJSON(object: nil)
        XCTAssert(response == nil)
        response = JSONHelper.prettyJSON(object: JSONHelper.convertToObject("{\"key\": \"value\"}").parsedObject)
        XCTAssert(response == "{\n  \"key\" : \"value\"\n}")
    }

    func testReduce() {
        let objects = ["mainKey": [["key1": ["A": 1, "B": true], "key2": false], ["key1": ["C": 1.2, "D": ["X": 1]], "key3": 3.4]]]
        let result = JSON(["mainKey": [["key2": false, "key3": 3.4, "key1": ["C": 1.2, "A": 1, "B": true, "D": ["X": 1]]]]])
        let reducedObject = JSONHelper.reduce([JSON(objects)])
        XCTAssert(reducedObject["mainKey"].array![0]["key1"] == result["mainKey"].array![0]["key1"])
        XCTAssert(reducedObject["mainKey"].array![0]["key2"] == result["mainKey"].array![0]["key2"])
        XCTAssert(reducedObject["mainKey"].array![0]["key3"] == result["mainKey"].array![0]["key3"])
        XCTAssert(JSONHelper.reduce([JSON(objects)]) == JSON(result))
    }

    func testJSONExtension() {
        let object = JSON(["key1": "string",
                           "key2": true,
                           "key3": [1, 2, 3],
                           "key4": NSNumber(integerLiteral: 20),
                           "key5": 10,
                           "key6": 10.5,
                           "key7": NSNull(),
                           "key8": ["A": "value"]])

        print(object["key1"].detailedValueType())
        XCTAssert(object["key1"].detailedValueType() == .string)
        XCTAssert(object["key2"].detailedValueType() == .bool)
        XCTAssert(object["key3"].detailedValueType() == .array)
        XCTAssert(object["key4"].detailedValueType() == .int)
        XCTAssert(object["key5"].detailedValueType() == .int)
        XCTAssert(object["key6"].detailedValueType() == .float)
        XCTAssert(object["key7"].detailedValueType() == .null)
        XCTAssert(object["key8"].detailedValueType() == .object)
    }
}
