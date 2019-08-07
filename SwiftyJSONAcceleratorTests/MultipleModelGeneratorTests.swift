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
        let manager = FileManager.default
        let path = "/tmp/random/folder"
        do {
            try manager.removeItem(atPath: path)
        } catch {}
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

    func testModelGenerationError() {
        let noFiles: MultipleModelGeneratorError = .noJSONFiles
        let noConfigFile: MultipleModelGeneratorError = .noConfigFile
        let invalidConfigJSON: MultipleModelGeneratorError = .invalidConfigJSON
        let invalidPath: MultipleModelGeneratorError = .invalidPath
        let configInvalid: MultipleModelGeneratorError = .configInvalid(rule: "Config Error")
        let invalidJSONFile: MultipleModelGeneratorError = .invalidJSONFile(filename: "InvalidJSONFile")

        XCTAssertEqual(noFiles.errorMessage(), "No JSON file at the given path.")
        XCTAssertEqual(noConfigFile.errorMessage(), "No .config.json was found at the path.")
        XCTAssertEqual(invalidConfigJSON.errorMessage(), "The .config.json has an invalid JSON.")
        XCTAssertEqual(invalidPath.errorMessage(), "The path is invalid.")
        XCTAssertEqual(configInvalid.errorMessage(), "Config Error")
        XCTAssertEqual(invalidJSONFile.errorMessage(), "The file InvalidJSONFile is invalid.")
    }

    func testMultipleFileGeneratorErrorCases() {
        let invalidPath: MultipleModelGeneratorError = .invalidPath
        XCTAssertThrowsError(try MultipleModelGenerator.generate(forPath: "/random/path/doesnot/exists"), "invalid folder") { error in
            XCTAssertEqual((error as? MultipleModelGeneratorError)!, invalidPath)
        }

        let manager = FileManager.default
        let path = "/tmp/random/folder/"
        try! manager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        let noJSONFiles: MultipleModelGeneratorError = .noJSONFiles
        XCTAssertThrowsError(try MultipleModelGenerator.generate(forPath: path), "invalid folder") { error in
            XCTAssertEqual((error as? MultipleModelGeneratorError)!, noJSONFiles)
        }

        manager.createFile(atPath: "/tmp/random/folder/tempfile.json", contents: "Data".data(using: .utf8), attributes: nil)
        sleep(2)
        let noConfigFile: MultipleModelGeneratorError = .noConfigFile
        XCTAssertThrowsError(try MultipleModelGenerator.generate(forPath: path), "invalid folder") { error in
            XCTAssertEqual((error as? MultipleModelGeneratorError)!, noConfigFile)
        }

        manager.createFile(atPath: "/tmp/random/folder/.config.json", contents: "NO_REAL_JSON".data(using: .utf8), attributes: nil)
        sleep(2)
        let invalidConfigJSON: MultipleModelGeneratorError = .invalidConfigJSON
        XCTAssertThrowsError(try MultipleModelGenerator.generate(forPath: path), "invalid folder") { error in
            XCTAssertEqual((error as? MultipleModelGeneratorError)!, invalidConfigJSON)
        }

        manager.createFile(atPath: "/tmp/random/folder/.config.json", contents: "[]".data(using: .utf8), attributes: nil)
        sleep(2)
        let invalidJSONFile: MultipleModelGeneratorError = .invalidJSONFile(filename: "tempfile.json")
        XCTAssertThrowsError(try MultipleModelGenerator.generate(forPath: path), "invalid folder") { error in
            XCTAssertEqual((error as? MultipleModelGeneratorError)!, invalidJSONFile)
        }
    }

    func testFilePathAndLoading() {
        // Test how invalid files are loaded.
        XCTAssertEqual(MultipleModelGenerator.loadJSON(fromFile: "/tmp/random/random"), nil)

        // Test how destination file paths are generated with different path types (absolute, relative, missing / etc)
        XCTAssertEqual(MultipleModelGenerator.generatePathToSave(fromBasePath: "/tmp/random/", destinationPath: "generatedFiles"), "/tmp/random/generatedFiles/")
        XCTAssertEqual(MultipleModelGenerator.generatePathToSave(fromBasePath: "/tmp/random", destinationPath: "generatedFiles"), "/tmp/random/generatedFiles/")
        XCTAssertEqual(MultipleModelGenerator.generatePathToSave(fromBasePath: "/tmp/random", destinationPath: "/generatedFiles"), "/generatedFiles/")

        let tempModelFile = SwiftJSONModelFile()
        XCTAssertEqual(MultipleModelGenerator.merge(models: [tempModelFile]).count, 1)
    }
}
