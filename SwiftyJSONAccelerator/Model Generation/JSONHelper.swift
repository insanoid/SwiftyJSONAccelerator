//
//  JSONHelper.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 16/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

/// Provides helpers to handle JSON content that user provides.
public class JSONHelper {

    /**
     Validates if the string that is provided can be converted into a valid JSON.

     - parameters:
     - jsonString: Input string that is to be checked as JSON.

     - returns: Bool indicating if it is a JSON or NSError with the error about the validation.
     */
    public class func isStringValidJSON(jsonString: String?) -> (Bool, NSError?) {
        let response = convertToObject(jsonString)
        return (response.0, response.2)
    }

    /**
     Converts the given string into an Object.

     - parameters:
     - jsonString: Input string that has to be converted.

     - returns: Bool indicating if the process was successful, Object if it worked else NSError.
     */
    public class func convertToObject(jsonString: String?) -> (Bool, AnyObject?, NSError?) {

        if jsonString == nil {
            return (false, nil, nil)
        }

        let jsonData = jsonString!.dataUsingEncoding(NSUTF8StringEncoding)!
        do {
            let object = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments)
            return (true, object, nil)
        }
        catch let error as NSError {
            return (false, nil, error)
        }
    }

    /**
     Formats the given string into beautiful JSON with indentation.

     - parameters:
     - jsonString: JSON string that has to be formatted.

     - returns: String with JSON but well formatted.
     */
    public class func prettyJSON(jsonString: String?) -> String? {
        let response = convertToObject(jsonString)
        if response.0 {
            return prettyJSON(response.1)
        } else {
            return nil
        }
    }

    /**
     Formats the given Object into beautiful JSON with indentation.

     - parameters:
     - object: Object that has to be formatted.

     - returns: String with JSON but well formatted.
     */
    public class func prettyJSON(object: AnyObject?) -> String? {

        if object == nil {
            return nil
        }

        do {
            let data: NSData = try NSJSONSerialization.dataWithJSONObject(object!, options: NSJSONWritingOptions.PrettyPrinted)
            return String.init(data: data, encoding: NSUTF8StringEncoding)
        }
        catch _ as NSError {
            return nil
        }
    }

}