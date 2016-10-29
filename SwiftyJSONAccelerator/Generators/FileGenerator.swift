//
//  FileGenerator.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 09/07/2016.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

struct FileGenerator {

  /**
   Fetch the template for creating model.swift files.

   - parameter filename: Name of the file to be loaded

   - returns: String containing the template.
   */
  static func loadFileWith(_ filename: String) -> String {

    let bundle = Bundle.main
    let path = bundle.path(forResource: filename, ofType: "txt")

    do {
      let content = try String.init(contentsOfFile: path!)
      return content
    } catch { }

    return ""
  }

  static func generateFileContentWith(_ modelFile: ModelFile, configuration: ModelGenerationConfiguration) -> String {

    var content = loadFileWith("BaseTemplate")
    content = content.replacingOccurrences(of: "{OBJECT_NAME}", with: modelFile.fileName)
    content = content.replacingOccurrences(of: "{DATE}", with: todayDateString())
    content = content.replacingOccurrences(of: "{OBJECT_KIND}", with: modelFile.type.rawValue)
    content = content.replacingOccurrences(of: "{JSON_PARSER_LIBRARY_BODY}", with: loadFileWith(modelFile.mainBodyFileName()))
    if let authorName = configuration.authorName {
      content = content.replacingOccurrences(of: "__NAME__", with: authorName)
    }
    if let companyName = configuration.companyName {
      content = content.replacingOccurrences(of: "__MyCompanyName__", with: companyName)
    }
    content = content.replacingOccurrences(of: "{INCLUDE_HEADER}", with: "\nimport \(modelFile.moduleName())")

    var classesExtendFrom: [String] = []
    if let extendFrom = modelFile.baseElementName() {
      classesExtendFrom = [extendFrom]
    }
    if configuration.supportNSCoding && configuration.constructType == .ClassType {
      classesExtendFrom = classesExtendFrom + ["NSCoding"]
    }

    if classesExtendFrom.count > 0 {
      content = content.replacingOccurrences(of: "{EXTEND_FROM}", with: classesExtendFrom.joined(separator: ", "))
      content = content.replacingOccurrences(of: "{EXTENDED_OBJECT_COLON}", with: ": ")
    } else {
      content = content.replacingOccurrences(of: "{EXTEND_FROM}", with: "")
      content = content.replacingOccurrences(of: "{EXTENDED_OBJECT_COLON}", with: "")
    }

    let stringConstants = modelFile.component.stringConstants.map({ "  " + $0 }).joined(separator: "\n")
    let declarations = modelFile.component.declarations.map({ "  " + $0 }).joined(separator: "\n")
    let initialisers = modelFile.component.initialisers.map({ "    " + $0 }).joined(separator: "\n")
    let description = modelFile.component.description.map({ "    " + $0 }).joined(separator: "\n")

    content = content.replacingOccurrences(of: "{STRING_CONSTANT}", with: stringConstants)
    content = content.replacingOccurrences(of: "{DECLARATION}", with: declarations)
    content = content.replacingOccurrences(of: "{INITALIZER}", with: initialisers)
    content = content.replacingOccurrences(of: "{DESCRIPTION}", with: description)

    if configuration.constructType == .StructType {
      content = content.replacingOccurrences(of: " convenience", with: "")
    }

    if configuration.supportNSCoding && configuration.constructType == .ClassType {
      content = content.replacingOccurrences(of: "{NSCODING_SUPPORT}", with: loadFileWith("NSCodingTemplate"))
      let encoders = modelFile.component.encoders.map({ "    " + $0 }).joined(separator: "\n")
      let decoders = modelFile.component.decoders.map({ "    " + $0 }).joined(separator: "\n")
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
  static internal func writeToFileWith(_ name: String, content: String, path: String) -> Bool {
    let filename = path.appendingFormat("%@", (name + ".swift"))
    do {
      try FileManager.default.createDirectory(at: URL.init(fileURLWithPath: path),
                                          withIntermediateDirectories: true,
                                          attributes: nil)
      try content.write(toFile: filename, atomically: true, encoding: String.Encoding.utf8)
      return true
    } catch let error as NSError {
        print(error)
      return false
    }
  }

  static fileprivate func todayDateString() -> String {
    let formatter = DateFormatter.init()
    formatter.dateStyle = .short
    return formatter.string(from: Date.init())
  }

}
