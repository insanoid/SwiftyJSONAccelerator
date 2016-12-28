//
//  FileGenerator.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 27/12/2016.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

/// Since we cannot have resources in the CLI we need to store strings here.
struct FileGenerator {

    /**
     Fetch the template for creating model.swift files.
     
     - parameter filename: Name of the file to be loaded
     
     - returns: String containing the template.
     */
    static func loadFileWith(_ filename: String) -> String {
        do {
            let content = try stringFor(filename: filename)
            return content
        } catch { }

        return ""
    }

    static func stringFor(filename: String) throws -> String {
        switch filename {
        case "MarshalTemplate":
            return "  // MARK: Marshal Initializers\n\n  /// Map a JSON object to this class using Marshal.\n  ///\n  /// - parameter object: A mapping from ObjectMapper\n  public{REQUIRED}init(object: MarshaledObject) {\n{INITIALIZER}\n  }\n"
        case "ObjectMapperTemplate":
            return "  // MARK: ObjectMapper Initializers\n  /// Map a JSON object to this class using ObjectMapper.\n  ///\n  /// - parameter map: A mapping from ObjectMapper.\n  public{REQUIRED}init?(map: Map){\n\n  }\n\n  /// Map a JSON object to this class using ObjectMapper.\n  ///\n  /// - parameter map: A mapping from ObjectMapper.\n  public func mapping(map: Map) {\n{INITIALIZER}\n  }\n"
        case "SwiftyJSONTemplate":
            return "  // MARK: SwiftyJSON Initializers\n  /// Initiates the instance based on the object.\n  ///\n  /// - parameter object: The object of either Dictionary or Array kind that was passed.\n  /// - returns: An initialized instance of the class.\n  public convenience init(object: Any) {\n    self.init(json: JSON(object))\n  }\n\n  /// Initiates the instance based on the JSON that was passed.\n  ///\n  /// - parameter json: JSON object from SwiftyJSON.\n  public{REQUIRED}init(json: JSON) {\n{INITIALIZER}\n  }\n"
        case "BaseTemplate":
            return "//\n//  {OBJECT_NAME}.swift\n//\n//  Created by __NAME__ on {DATE}\n//  Copyright (c) __MyCompanyName__. All rights reserved.\n//\n\nimport Foundation{INCLUDE_HEADER}\n\npublic{IS_FINAL}{OBJECT_KIND} {OBJECT_NAME}{EXTENDED_OBJECT_COLON}{EXTEND_FROM} {\n\n  // MARK: Declaration for string constants to be used to decode and also serialize.\n  private struct SerializationKeys {\n{STRING_CONSTANT}\n  }\n\n  // MARK: Properties\n{DECLARATION}\n\n{JSON_PARSER_LIBRARY_BODY}\n  /// Generates description of the object in the form of a NSDictionary.\n  ///\n  /// - returns: A Key value pair containing all valid values in the object.\n  public func dictionaryRepresentation() -> [String: Any] {\n    var dictionary: [String: Any] = [:]\n{DESCRIPTION}\n    return dictionary\n  }\n{NSCODING_SUPPORT}\n}\n"
        case "NSCodingTemplate":
            return "\n  // MARK: NSCoding Protocol\n  required public init(coder aDecoder: NSCoder) {\n{DECODERS}\n  }\n\n  public func encode(with aCoder: NSCoder) {\n{ENCODERS}\n  }\n"
        default:
            throw NSError.init(domain: "SwiftyJSONAccelerator", code: 0, userInfo: nil)
        }
    }
}
