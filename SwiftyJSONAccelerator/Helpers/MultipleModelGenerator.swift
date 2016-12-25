//
//  MultipleModelGenerator.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 24/12/2016.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation
import SwiftyJSON


/// An enumeration for handling various kinds of errors generated from multiple model generator.
///
/// - noJSONFiles: No JSON file was found at the location.
/// - noConfigFile: No configuration file was found at the location.
/// - configInvalid: Configuration provided is invalid.
/// - invalidJSONFile: Invalid JSON file.
/// - invalidConfigJSON: JSON file for config is invalid.
/// - invalidPath: The filepath is invalid.
enum MultipleModelGeneratorError: Error {
    case noJSONFiles
    case noConfigFile
    case configInvalid(rule: String)
    case invalidJSONFile(filename: String)
    case invalidConfigJSON
    case invalidPath


    /// Generate an error message for the error case.
    ///
    /// - Returns: Error message for the current case.
    func errorMessage() -> String {
        switch self {
        case .noJSONFiles:
            return NSLocalizedString("No JSON file at the given path.", comment: "")
        case .noConfigFile:
            return NSLocalizedString("No .config.json was found at the path.", comment: "")
        case .configInvalid(let rule):
            return rule
        case .invalidJSONFile(let filename):
            return "The file \(filename) is invalid."
        case .invalidConfigJSON:
            return "The .config.json has an invalid JSON."
        case .invalidPath:
            return "The path is invalid."
        }
    }
}


/// A structure to generate multiple mdoels from JSON files at once.
struct MultipleModelGenerator {


    /// Generate models for the JSON files in the given path. Use the `.config.json` to load config.
    ///
    /// - Parameter forPath: Path with the JSON files.
    /// - Returns: An array of model files.
    static func generate(forPath: String) throws -> (modelFiles: [ModelFile], configuration: ModelGenerationConfiguration) {
        let fileManager = FileManager.default
        var isDir: ObjCBool = true
        guard fileManager.fileExists(atPath: forPath, isDirectory: &isDir) else {
            throw MultipleModelGeneratorError.invalidPath
        }

        let response = filesIn(path: forPath)
        if response.files.count <= 0 {
            throw MultipleModelGeneratorError.noJSONFiles
        }

        guard let configPath = response.configFile else {
            throw MultipleModelGeneratorError.noConfigFile
        }

        guard let configJSON = loadJSON(fromFile: configPath) else {
            throw MultipleModelGeneratorError.invalidConfigJSON
        }

        /// The final configuration for the models (without filename)
        let config = try loadConfiguration(fromJSON: configJSON)

        guard var finalConfiguration = config else {
            throw MultipleModelGeneratorError.configInvalid(rule: NSLocalizedString("Invalid configration.", comment: ""))
        }

        /// If there is no file path, put the default path in.
        if finalConfiguration.filePath == "" {
            finalConfiguration.filePath = forPath
        }

        var models = [ModelFile]()
        for file in response.files {
            let url = URL.init(fileURLWithPath: file)
            let fileName = url.lastPathComponent.replacingOccurrences(of: ".swift", with: "")
            if let json = loadJSON(fromFile: file) {
                finalConfiguration.baseClassName = fileName
                let m = ModelGenerator.init(json, finalConfiguration)
                models.append(contentsOf: m.generate())
            } else {
                throw MultipleModelGeneratorError.invalidJSONFile(filename: url.lastPathComponent)
            }
        }

        return (models, finalConfiguration)
    }


    /// Fetch the files in the path, both normal JSON file and config files.
    ///
    /// - Parameter path: Path which has to be scanned.
    /// - Returns: An array of JSON files and a configuration file.
    static func filesIn(path: String) -> (files: [String], configFile: String?) {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: path)
        var jsonFiles = [String]()
        var configFile: String?
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix("json") {
                if element == ".config.json" {
                    configFile = path + "/" + element
                } else {
                    jsonFiles.append(path + "/" + element)
                }
            }
        }
        return (jsonFiles, configFile)
    }


    /// Load configuration file from the provided JSON.
    ///
    /// - Parameter fromJSON: JSON file with configuration properties.
    /// - Returns: Configuration model.
    /// - Throws: `MultipleModelGeneratorError.configInvalid` error.
    static func loadConfiguration(fromJSON: JSON) throws -> ModelGenerationConfiguration? {
        var constructType = ConstructType.ClassType
        if let type = fromJSON["construct_type"].string, type == "struct" {
            constructType = ConstructType.StructType
        }
        var jsonLibrary = JSONMappingLibrary.SwiftyJSON
        if let type = fromJSON["model_mapping_library"].string {
            if type == JSONMappingLibrary.ObjectMapper.rawValue {
                jsonLibrary = JSONMappingLibrary.ObjectMapper
            } else if type == JSONMappingLibrary.Marshal.rawValue {
                jsonLibrary = JSONMappingLibrary.Marshal
            }
        }
        let config = ModelGenerationConfiguration.init(filePath: fromJSON["destination_path"].string ?? "",
                                                       baseClassName: "",
                                                       authorName: fromJSON["author_name"].string,
                                                       companyName: fromJSON["company_name"].string,
                                                       prefix: fromJSON["prefix"].string,
                                                       constructType: constructType,
                                                       modelMappingLibrary: jsonLibrary,
                                                       supportNSCoding: fromJSON["support_nscoding"].boolValue,
                                                       isFinalRequired: fromJSON["is_final_required"].boolValue,
                                                       isHeaderIncluded: fromJSON["is_header_included"].boolValue)

        let response = config.isConfigurationValid()
        if response.isValid {
            return config
        } else {
            throw MultipleModelGeneratorError.configInvalid(rule: response.reason)
        }
    }


    /// Load a JSON file from the file at the given path.
    ///
    /// - Parameter fromFile: Filepath for the JSON file.
    /// - Returns: JSON object or nil.
    private static func loadJSON(fromFile: String) -> JSON? {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fromFile) == false {
            return nil
        }
        let url = URL.init(fileURLWithPath: fromFile)
        do {
            let jsonData = try Data.init(contentsOf: url, options: Data.ReadingOptions.uncached)
            return JSON.init(data: jsonData)
        } catch {
            return nil
        }
    }

}
