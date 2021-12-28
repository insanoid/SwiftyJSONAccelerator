//
//  JSONHelper.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 16/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Foundation
import SwiftyJSON

/// A structure to store JSON parsed response in a systematic manner
struct JSONParserResponse {
    let parsedObject: AnyObject?
    let error: NSError?

    /// Provides a easy way to know if the response is valid or not.
    var isValid: Bool {
        return parsedObject != nil
    }
}

/// Provide helpers to handle JSON content that the user provided.
enum JSONHelper {
    /// Validate if the string that is provided can be converted into a valid JSON.
    ///
    /// - Parameter jsonString: Input string that is to be checked as JSON.
    /// - Returns: Bool indicating if it is a JSON or NSError with the error about the validation.
    static func isStringValidJSON(_ jsonString: String?) -> JSONParserResponse {
        return convertToObject(jsonString)
    }

    /// Convert the given string into an object.
    ///
    /// - Parameter jsonString: Input string that needs to be converted.
    /// - Returns: `JSONParserResponse` which contains the parsed object or the error.
    static func convertToObject(_ jsonString: String?) -> JSONParserResponse {
        guard let jsonValueString = jsonString else { return JSONParserResponse(parsedObject: nil, error: nil) }
        let jsonData = jsonValueString.data(using: String.Encoding.utf8)!
        do {
            let object = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments)
            return JSONParserResponse(parsedObject: object as AnyObject?, error: nil)
        } catch let error as NSError {
            return JSONParserResponse(parsedObject: nil, error: error)
        }
    }

    /// Formats the given string into beautiful JSON with indentation.
    ///
    /// - Parameter jsonString: JSON string that has to be formatted.
    /// - Returns: String with JSON but well formatted.
    static func prettyJSON(_ jsonString: String?) -> String? {
        let response = convertToObject(jsonString)
        if response.isValid {
            return prettyJSON(object: response.parsedObject)
        }
        return nil
    }

    /// Format the given Object into beautiful JSON with indentation.
    ///
    /// - Parameter passedObject: Object that has to be formatted.
    /// - Returns: String with JSON but well formatted.
    static func prettyJSON(object passedObject: AnyObject?) -> String? {
        guard let object = passedObject else { return nil }

        do {
            let data = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
            return String(data: data, encoding: String.Encoding.utf8)
        } catch {
            return nil
        }
    }

    /// Reduce an array of JSON objects to a single JSON object with all possible keys (merge all keys into one single object).
    ///
    /// - Parameter items: An array of JSON items that have to be reduced.
    /// - Returns: Reduced JSON with the common key/value pairs.
    static func reduce(_ items: [JSON]) -> JSON {
        return items.reduce([:]) { (source, item) -> JSON in
            var finalObject = source
            for (key, jsonValue) in item {
                if let newValue = jsonValue.dictionary {
                    finalObject[key] = reduce([JSON(newValue), finalObject[key]])
                } else if let newValue = jsonValue.array, newValue.first != nil && (newValue.first!.dictionary != nil || newValue.first!.array != nil) {
                    finalObject[key] = JSON([reduce(newValue + finalObject[key].arrayValue)])
                } else if jsonValue != JSON.null || !finalObject[key].exists() {
                    finalObject[key] = jsonValue
                }
            }
            return finalObject
        }
    }
}

// Helper methods for JSON Object
extension JSON {
    /// Extensive value types with differentiation between the number types.
    ///
    /// - Returns: Value type of the JSON value
    func detailedValueType() -> VariableType {
        switch type {
        case .string:
            return .string
        case .bool:
            return .bool
        case .array:
            return .array
        case .number:
            switch CFNumberGetType(numberValue as CFNumber) {
            case .sInt8Type,
                 .sInt16Type,
                 .sInt32Type,
                 .sInt64Type,
                 .charType,
                 .shortType,
                 .intType,
                 .longType,
                 .longLongType,
                 .cfIndexType,
                 .nsIntegerType:
                return .int
            case .float32Type,
                 .float64Type,
                 .floatType,
                 .cgFloatType,
                 .doubleType:
                return .float
            // Covers any future types for CFNumber.
            @unknown default:
                return .float
            }
        case .null:
            return .null
        default:
            return .object
        }
    }
}
