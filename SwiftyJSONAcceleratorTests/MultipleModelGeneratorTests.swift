//
//  MultipleModelGeneratorTests.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 24/12/2016.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation
import XCTest

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
            let testBundle = Bundle(for: type(of: self))
            if let path = testBundle.path(forResource: "album", ofType: ".json") {
                let folderPath = path.replacingOccurrences(of: "album.json", with: "")
                let generatedModelInfo = try MultipleModelGenerator.generate(forPath: folderPath)
                XCTAssertEqual(generatedModelInfo.modelFiles.count, 6)
                for file in generatedModelInfo.modelFiles {
                    let content = FileGenerator.generateFileContentWith(file, configuration: generatedModelInfo.configuration)
                    let name = file.fileName
                    let path = generatedModelInfo.configuration.filePath
                    do {
                        try FileGenerator.writeToFileWith(name, content: content, path: path)
                    } catch {
                        assertionFailure("File generation failed.")
                    }
                }
            } else {
                assertionFailure("File generation failed - Nothing found at the path.")
            }
        } catch {
            assertionFailure("Something went wrong with model generation.")
        }
    }
}
