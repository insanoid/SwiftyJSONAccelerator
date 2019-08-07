//
//  FileGeneratorTests.swift
//  SwiftyJSONAcceleratorTests
//
//  Created by Karthikeya Udupa on 06/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import XCTest

class FileGeneratorTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInvalidPath() {
        let value = try! FileGenerator.loadFileWith("doesNotExist")
        XCTAssertEqual(value, "")
    }

    func loadValidPath() {
        let fileContent = try! FileGenerator.loadFileWith("BaseTemplate")
        XCTAssert(!fileContent.isEmpty)
    }
}
