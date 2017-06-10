//
//  FileGenerator.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 27/12/2016.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

extension FileGenerator {

    static func generateFileContentWith(_ modelFile: ModelFile, configuration: ModelGenerationConfiguration) -> String {

        var content = loadFileWith("BaseTemplate")
        let singleTab = "  ", doubleTab = "    "
        content = content.replacingOccurrences(of: "{OBJECT_NAME}", with: modelFile.fileName)
        content = content.replacingOccurrences(of: "{DATE}", with: todayDateString())
        content = content.replacingOccurrences(of: "{OBJECT_KIND}", with: modelFile.type.rawValue)
        content = content.replacingOccurrences(of: "{JSON_PARSER_LIBRARY_BODY}", with: loadFileWith(modelFile.mainBodyTemplateFileName()))

        if modelFile.type == .classType {
            content = content.replacingOccurrences(of: "{REQUIRED}", with: " required ")
        } else {
            content = content.replacingOccurrences(of: "{REQUIRED}", with: " ")
        }
        if let authorName = configuration.authorName {
            content = content.replacingOccurrences(of: "__NAME__", with: authorName)
        }
        if let companyName = configuration.companyName {
            content = content.replacingOccurrences(of: "__MyCompanyName__", with: companyName)
        }
        if configuration.isFinalRequired {
            content = content.replacingOccurrences(of: "{INCLUDE_HEADER}", with: "\nimport \(modelFile.moduleName())")
        } else {
            content = content.replacingOccurrences(of: "{INCLUDE_HEADER}", with: "")
        }

        var classesExtendFrom: [String] = []
        if let extendFrom = modelFile.baseElementName() {
            classesExtendFrom = [extendFrom]
        }
        if configuration.supportNSCoding && configuration.constructType == .classType {
            classesExtendFrom += ["NSCoding"]
        }

        if configuration.isFinalRequired && configuration.constructType == .classType {
            content = content.replacingOccurrences(of: "{IS_FINAL}", with: " final ")
        } else {
            content = content.replacingOccurrences(of: "{IS_FINAL}", with: " ")
        }

        if classesExtendFrom.count > 0 {
            content = content.replacingOccurrences(of: "{EXTEND_FROM}", with: classesExtendFrom.joined(separator: ", "))
            content = content.replacingOccurrences(of: "{EXTENDED_OBJECT_COLON}", with: ": ")
        } else {
            content = content.replacingOccurrences(of: "{EXTEND_FROM}", with: "")
            content = content.replacingOccurrences(of: "{EXTENDED_OBJECT_COLON}", with: "")
        }

        let stringConstants = modelFile.component.stringConstants.map({ doubleTab + $0 }).joined(separator: "\n")
        let declarations = modelFile.component.declarations.map({ singleTab + $0 }).joined(separator: "\n")
        let initialisers = modelFile.component.initialisers.map({ doubleTab + $0 }).joined(separator: "\n")
        let description = modelFile.component.description.map({ doubleTab + $0 }).joined(separator: "\n")

        content = content.replacingOccurrences(of: "{STRING_CONSTANT}", with: stringConstants)
        content = content.replacingOccurrences(of: "{DECLARATION}", with: declarations)
        content = content.replacingOccurrences(of: "{INITIALIZER}", with: initialisers)
        content = content.replacingOccurrences(of: "{DESCRIPTION}", with: description)

        if configuration.constructType == .structType {
            content = content.replacingOccurrences(of: " convenience", with: "")
        }

        if configuration.supportNSCoding && configuration.constructType == .classType {
            content = content.replacingOccurrences(of: "{NSCODING_SUPPORT}", with: loadFileWith("NSCodingTemplate"))
            let encoders = modelFile.component.encoders.map({ doubleTab + $0 }).joined(separator: "\n")
            let decoders = modelFile.component.decoders.map({ doubleTab + $0 }).joined(separator: "\n")
            content = content.replacingOccurrences(of: "{DECODERS}", with: decoders)
            content = content.replacingOccurrences(of: "{ENCODERS}", with: encoders)
        } else {
            content = content.replacingOccurrences(of: "{NSCODING_SUPPORT}", with: "")
        }

        return content
    }

    /**
     Write the given content to a file at the mentioned path.
     
     - parameter name:      The name of the file.
     - parameter content:   Content that has to be written on the file.
     - parameter path:      Path where the file has to be created.
     
     - returns: Boolean indicating if the process was successful.
     */
    static internal func writeToFileWith(_ name: String, content: String, path: String) throws {
        let filename = path.appendingFormat("%@", (name + ".swift"))
        try FileManager.default.createDirectory(at: URL.init(fileURLWithPath: path),
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        try content.write(toFile: filename, atomically: true, encoding: String.Encoding.utf8)
    }

    static fileprivate func todayDateString() -> String {
        let formatter = DateFormatter.init()
        formatter.dateStyle = .short
        return formatter.string(from: Date.init())
    }
}
