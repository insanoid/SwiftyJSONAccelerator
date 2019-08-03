//
//  ModelGeneratorTests.swift
//  SwiftyJSONAcceleratorTests
//
//  Created by Karthikeya Udupa on 03/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Foundation
import XCTest

class ModelGeneratorTests: XCTestCase {
    override func setUp() {
        super.setUp()
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
    }

    override func tearDown() {
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
