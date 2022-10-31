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
        var content = try! loadFileWith("BaseTemplate")
        let singleTab = "  ", doubleTab = "    "
        let accessPrefix = modelFile.accessControl.declarationPrefix
        content = content.replacingOccurrences(of: "{OBJECT_NAME}", with: modelFile.fileName)
        content = content.replacingOccurrences(of: "{DATE}", with: todayDateString())
        content = content.replacingOccurrences(of: "{OBJECT_KIND}", with: modelFile.type.rawValue)
        content = content.replacingOccurrences(of: "{ACCESS_CONTROL}", with: accessPrefix)

        if let authorName = configuration.authorName {
            content = content.replacingOccurrences(of: "__NAME__", with: authorName)
        }
        if let companyName = configuration.companyName {
            content = content.replacingOccurrences(of: "__MyCompanyName__", with: companyName)
        }

        let stringConstants = modelFile.component.stringConstants.map { doubleTab + $0 }.joined(separator: "\n")
        let declarations = modelFile.component.declarations.map { singleTab + $0 }.joined(separator: "\n")
        let initialisers = modelFile.component.initialisers.map { doubleTab + $0 }.joined(separator: "\n")

        content = content.replacingOccurrences(of: "{STRING_CONSTANT}", with: stringConstants)
        content = content.replacingOccurrences(of: "{DECLARATION}", with: declarations)
        content = content.replacingOccurrences(of: "{INITIALIZER}", with: initialisers)

        if modelFile.type == .classType {
            content = content.replacingOccurrences(of: "{REQUIRED}", with: "required ")
            if modelFile.configuration?.shouldGenerateInitMethod == true {
                let assignment = modelFile.component.initialiserFunctionComponent.map { doubleTab + $0.assignmentString }.joined(separator: "\n")
                let functionParameters = modelFile.component.initialiserFunctionComponent.map { $0.functionParameter }.joined(separator: ", ")
                let initialiserFunctionStatement = "\n\(singleTab)\(accessPrefix)init (\(functionParameters)) {"
                content = content.replacingOccurrences(of: "{INITIALIZER_FUNCTION_DECLRATION}", with: initialiserFunctionStatement)
                content = content.replacingOccurrences(of: "{INITIALISER_FUNCTION_ASSIGNMENT}", with: assignment)
                content = content.replacingOccurrences(of: "{INITIALISER_FUNCTION_END}", with: "\(singleTab)}\n")
            }
        } else {
            content = content.replacingOccurrences(of: "{REQUIRED}", with: "")
            content = content.replacingOccurrences(of: "{INITIALIZER_FUNCTION_DECLRATION}", with: "")
            content = content.replacingOccurrences(of: "{INITIALISER_FUNCTION_ASSIGNMENT}", with: "")
            content = content.replacingOccurrences(of: "{INITIALISER_FUNCTION_END}", with: "")
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
    static func writeToFileWith(_ name: String, content: String, path: String) throws {
        let filename = path.appendingFormat("%@", name + ".swift")
        try FileManager.default.createDirectory(at: URL(fileURLWithPath: path),
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        try content.write(toFile: filename, atomically: true, encoding: String.Encoding.utf8)
    }

    fileprivate static func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: Date())
    }
}
