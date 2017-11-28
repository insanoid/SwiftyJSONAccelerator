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
			return """
			// MARK: Marshal Initializers

			/// Map a JSON object to this class using Marshal.
			///
			/// - parameter object: A mapping from ObjectMapper
			public{REQUIRED}init(object: MarshaledObject) {
			{INITIALIZER}
			}

			"""
		case "ObjectMapperTemplate":
			return """
			// MARK: ObjectMapper Initializers
			/// Map a JSON object to this class using ObjectMapper.
			///
			/// - parameter map: A mapping from ObjectMapper.
			public{REQUIRED}init?(map: Map){

			}

			/// Map a JSON object to this class using ObjectMapper.
			///
			/// - parameter map: A mapping from ObjectMapper.
			public func mapping(map: Map) {
			{INITIALIZER}
			}
			"""
		case "Swift4Template":
			return """
			"""
		case "SwiftyJSONTemplate":
			return
			"""
			// MARK: SwiftyJSON Initializers
			/// Initiates the instance based on the object.
			///
			/// - parameter object: The object of either Dictionary or Array kind that was passed.
			/// - returns: An initialized instance of the class.
			public convenience init(object: Any) {
			self.init(json: JSON(object))
			}

			/// Initiates the instance based on the JSON that was passed.
			///
			/// - parameter json: JSON object from SwiftyJSON.
			public{REQUIRED}init(json: JSON) {
			{INITIALIZER}
			}

			/// Generates description of the object in the form of a NSDictionary.
			///
			/// - returns: A Key value pair containing all valid values in the object.
			public func dictionaryRepresentation() -> [String: Any] {
			var dictionary: [String: Any] = [:]
			{DICTIONARY_REPRESENTATION_PARSER}
			return dictionary
			}
			"""
		case "BaseTemplate":
			return """
			//
			//  {OBJECT_NAME}.swift
			//
			//  Created by __NAME__ on {DATE}
			//  Copyright (c) __MyCompanyName__. All rights reserved.
			//

			import Foundation{INCLUDE_HEADER}

			public{IS_FINAL}{OBJECT_KIND} {OBJECT_NAME}{EXTENDED_OBJECT_COLON}{EXTEND_FROM} {

			// MARK: Declaration for string constants to be used to decode and also serialize.
			private struct SerializationKeys {
			{SERIALIZATION_KEYS_EACH}
			}

			// MARK: Properties
			{PROPERTY_DECLARATIONS}

			{JSON_PARSER_LIBRARY_BODY}
			/// Generates description of the object in the form of a NSDictionary.
			///
			/// - returns: A Key value pair containing all valid values in the object.
			public func dictionaryRepresentation() -> [String: Any] {
			var dictionary: [String: Any] = [:]
			{DICTIONARY_REPRESENTATION_PARSER}
			return dictionary
			}
			{NSCODING_SUPPORT}
			}
			"""
		case "NSCodingTemplate":
			return """
			// MARK: NSCoding Protocol
			required public init(coder aDecoder: NSCoder) {
			{DECODERS}
			}

			public func encode(with aCoder: NSCoder) {
			{ENCODERS}
			}
			"""
		default:
			throw NSError.init(domain: "SwiftyJSONAccelerator", code: 0, userInfo: nil)
		}
	}
}
