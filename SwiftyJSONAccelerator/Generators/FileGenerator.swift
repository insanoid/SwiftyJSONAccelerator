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
  static func loadFileWith(filename: String) -> String {

    let bundle = NSBundle.mainBundle()
    let path = bundle.pathForResource(filename, ofType: "txt")

    do {
      let content = try String.init(contentsOfFile: path!)
      return content
    } catch { }

    return ""
  }

  static func generateFileContentWith(modelFile: ModelFile, configuration: ModelGenerationConfiguration) -> String {

    var content = loadFileWith("BaseTemplate")
    content = content.stringByReplacingOccurrencesOfString("{OBJECT_NAME}", withString: modelFile.fileName)
    content = content.stringByReplacingOccurrencesOfString("{DATE}", withString: todayDateString())
    content = content.stringByReplacingOccurrencesOfString("{OBJECT_KIND}", withString: modelFile.type.rawValue)
    content = content.stringByReplacingOccurrencesOfString("{JSON_PARSER_LIBRARY_BODY}", withString: loadFileWith(modelFile.mainBodyFileName()))
    if let authorName = configuration.authorName {
      content = content.stringByReplacingOccurrencesOfString("__NAME__", withString: authorName)
    }
    if let companyName = configuration.companyName {
      content = content.stringByReplacingOccurrencesOfString("__MyCompanyName__", withString: companyName)
    }
    content = content.stringByReplacingOccurrencesOfString("{INCLUDE_HEADER}", withString: "\nimport \(modelFile.moduleName())")

    var classesExtendFrom: [String] = []
    if let extendFrom = modelFile.baseElementName() {
      classesExtendFrom = [extendFrom]
    }
    if configuration.supportNSCoding {
      classesExtendFrom = classesExtendFrom + ["NSCoding"]
    }

    if classesExtendFrom.count > 0 {
      content = content.stringByReplacingOccurrencesOfString("{EXTEND_FROM}", withString: classesExtendFrom.joinWithSeparator(", "))
      content = content.stringByReplacingOccurrencesOfString("{EXTENDED_OBJECT_COLON}", withString: ": ")
    } else {
      content = content.stringByReplacingOccurrencesOfString("{EXTEND_FROM}", withString: "")
      content = content.stringByReplacingOccurrencesOfString("{EXTENDED_OBJECT_COLON}", withString: "")
    }

    let stringConstants = modelFile.component.stringConstants.map({ "  " + $0 }).joinWithSeparator("\n")
    let declarations = modelFile.component.declarations.map({ "  " + $0 }).joinWithSeparator("\n")
    let initialisers = modelFile.component.initialisers.map({ "    " + $0 }).joinWithSeparator("\n")
    let description = modelFile.component.description.map({ "    " + $0 }).joinWithSeparator("\n")

    content = content.stringByReplacingOccurrencesOfString("{STRING_CONSTANT}", withString: stringConstants)
    content = content.stringByReplacingOccurrencesOfString("{DECLARATION}", withString: declarations)
    content = content.stringByReplacingOccurrencesOfString("{INITALIZER}", withString: initialisers)
    content = content.stringByReplacingOccurrencesOfString("{DESCRIPTION}", withString: description)

    if configuration.supportNSCoding {
      content = content.stringByReplacingOccurrencesOfString("{NSCODING_SUPPORT}", withString: loadFileWith("NSCodingTemplate"))
      let encoders = modelFile.component.encoders.map({ "    " + $0 }).joinWithSeparator("\n")
      let decoders = modelFile.component.decoders.map({ "    " + $0 }).joinWithSeparator("\n")
      content = content.stringByReplacingOccurrencesOfString("{DECODERS}", withString: decoders)
      content = content.stringByReplacingOccurrencesOfString("{ENCODERS}", withString: encoders)
    } else {
      content = content.stringByReplacingOccurrencesOfString("{NSCODING_SUPPORT}", withString: "")
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
  static internal func writeToFileWith(name: String, content: String, path: String) -> Bool {
    let filename = path.stringByAppendingFormat("/%@", (name.stringByAppendingString(".swift")))
    do {
      try content.writeToFile(filename, atomically: true, encoding: NSUTF8StringEncoding)
      return true
    } catch {
      return false
    }
  }

  static private func todayDateString() -> String {
    let formatter = NSDateFormatter.init()
    formatter.dateStyle = .ShortStyle
    return formatter.stringFromDate(NSDate.init())
  }

}
