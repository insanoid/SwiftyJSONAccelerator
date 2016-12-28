//
//  JSONHelper.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 16/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

/// Provides helpers to handle JSON content that user provides.
open class JSONHelper {

  /**
   Validates if the string that is provided can be converted into a valid JSON.

   - parameters:
   - jsonString: Input string that is to be checked as JSON.

   - returns: Bool indicating if it is a JSON or NSError with the error about the validation.
   */
  open class func isStringValidJSON(_ jsonString: String?) -> (Bool, NSError?) {
    let response = convertToObject(jsonString)
    return (response.0, response.2)
  }

  /**
   Converts the given string into an Object.

   - parameters:
   - jsonString: Input string that has to be converted.

   - returns: Bool indicating if the process was successful, Object if it worked else NSError.
   */
  open class func convertToObject(_ jsonString: String?) -> (Bool, AnyObject?, NSError?) {

    guard let jsonValueString = jsonString else { return (false, nil, nil) }

    let jsonData = jsonValueString.data(using: String.Encoding.utf8)!
    do {
      let object = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments)
      return (true, object as AnyObject?, nil)
    } catch let error as NSError {
      return (false, nil, error)
    }
  }

  /**
   Formats the given string into beautiful JSON with indentation.

   - parameters:
   - jsonString: JSON string that has to be formatted.

   - returns: String with JSON but well formatted.
   */
  open class func prettyJSON(_ jsonString: String?) -> String? {
    let response = convertToObject(jsonString)
    if response.0 {
      return prettyJSON(object: response.1)
    }
    return nil

  }

  /**
   Formats the given Object into beautiful JSON with indentation.

   - parameters:
   - object: Object that has to be formatted.

   - returns: String with JSON but well formatted.
   */
  open class func prettyJSON(object passedObject: AnyObject?) -> String? {

    guard let object = passedObject else { return nil }

    do {
      let data = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
      return String.init(data: data, encoding: String.Encoding.utf8)
    } catch {
      return nil
    }
  }

  /**
   Reduces an array of JSON to a single JSON with all possible keys.

   - parameter items: An array of JSON items that have to be reduced.

   - returns: Reduced JSON with the common key/value pairs.
   */
  class func reduce(_ items: [JSON]) -> JSON {

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
