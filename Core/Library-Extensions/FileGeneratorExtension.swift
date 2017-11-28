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

		var content: String = ""

		content = loadFileWith("BaseTemplate")

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

		if configuration.isFinalRequired, let moduleName = modelFile.moduleName() {
			content = content.replacingOccurrences(of: "{INCLUDE_HEADER}", with: "\nimport \(moduleName)")
        } else {
            content = content.replacingOccurrences(of: "{INCLUDE_HEADER}", with: "")
        }

		if configuration.modelMappingLibrary == .swift4 {
			content = content.replacingOccurrences(of: "{SERIALIZATION_KEYS_KIND}", with: "enum")
			content = content.replacingOccurrences(of: "{SERIALIZATION_KEYS_EXTENSIONS}", with: " : String, CodingKeys")
		} else {
			content = content.replacingOccurrences(of: "{SERIALIZATION_KEYS_KIND}", with: "struct")
			content = content.replacingOccurrences(of: "{SERIALIZATION_KEYS_EXTENSIONS}", with: "")
		}

        var classesExtendFrom: [String] = []

        if let extendFrom = modelFile.baseElementName() {
            classesExtendFrom = [extendFrom]
        }

        if configuration.supportNSCoding
			&& configuration.constructType == .classType
			&& configuration.modelMappingLibrary != .swift4 {
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

        let mappingConstants = modelFile.component.mappingConstants.map({ doubleTab + $0 }).joined(separator: "\n")
        let properties = modelFile.component.properties.map({ singleTab + $0 }).joined(separator: "\n")
        let initialisers = modelFile.component.initialisers.map({ doubleTab + $0 }).joined(separator: "\n")
        let dictionaryDescriptions = modelFile.component.dictionaryDescriptions.map({ doubleTab + $0 }).joined(separator: "\n")

        content = content.replacingOccurrences(of: "{SERIALIZATION_KEYS_EACH}", with: mappingConstants)
        content = content.replacingOccurrences(of: "{PROPERTY_DECLARATIONS}", with: properties)
        content = content.replacingOccurrences(of: "{INITIALIZER}", with: initialisers)
        content = content.replacingOccurrences(of: "{DICTIONARY_REPRESENTATION_PARSER}", with: dictionaryDescriptions)

        if configuration.constructType == .structType {
            content = content.replacingOccurrences(of: " convenience", with: "")
        }

        if configuration.supportNSCoding
			&& configuration.constructType == .classType
			&& configuration.modelMappingLibrary != .swift4 {

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

		let directoryURL = URL.init(fileURLWithPath: path)
		try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

		if FileManager.default.fileExists(atPath: filename) {
			try FileManager.default.removeItem(atPath: filename)
		}

        try content.write(toFile: filename, atomically: true, encoding: String.Encoding.utf8)
    }

    static fileprivate func todayDateString() -> String {
        let formatter = DateFormatter.init()
        formatter.dateStyle = .short
        return formatter.string(from: Date.init())
    }
}
