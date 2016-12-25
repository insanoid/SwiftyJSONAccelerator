//
//  MultipleModelGeneratorTests.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 24/12/2016.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import XCTest
import Nimble
import SwiftyJSON
import Foundation

/// Test for multiple model generator.
class MultipleModelGeneratorTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFileCheck() {
        
        do {
            let generatedModelInfo = try MultipleModelGenerator.generate(forPath: "/Users/karthikeyaudupa/Desktop/JSONFiles")
            expect(generatedModelInfo.modelFiles.count).to(equal(5))
            for file in generatedModelInfo.modelfiles {
                let content = FileGenerator.generateFileContentWith(file, configuration: generatedModelInfo.configuration)
                let name = file.fileName
                let path = generatedModelInfo.configuration.filePath
                expect(FileGenerator.writeToFileWith(name, content: content, path: path)).to(equal(true))
            }
        } catch {
            assertionFailure("Something went wrong with model generation.")
        }

    }
}
