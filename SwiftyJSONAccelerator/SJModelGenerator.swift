//
//  SJModelGenerator.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 20/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

//
//  ModelGenerator.swift
//  swiftin
//
//  Created by Philip Woods on 6/11/14.
//  Copyright (c) 2014 pvwoods. All rights reserved.
//

import Foundation

import Cocoa


public class ModelGenerator {
    
    class func buildClassName(className: String, suffix: String)  -> String {
        var classNameCleaned = variableNameBuilder(className)
        classNameCleaned.replaceRange(classNameCleaned.startIndex...classNameCleaned.startIndex, with: String(classNameCleaned[classNameCleaned.startIndex]).uppercaseString)
        return suffix.stringByAppendingString(classNameCleaned)
    }
    
    
    class func variableNameBuilder(variableName: String) -> String {
        var variableName = variableName.stringByReplacingOccurrencesOfString("_", withString: " ")
        variableName = variableName.capitalizedString
        variableName = variableName.stringByReplacingOccurrencesOfString(" ", withString: "")
        variableName.replaceRange(variableName.startIndex...variableName.startIndex, with: String(variableName[variableName.startIndex]).lowercaseString)
        return variableName
        
    }
    class func variableNameKeyBuilder(className: String, var variableName: String) -> String {
        variableName.replaceRange(variableName.startIndex...variableName.startIndex, with: String(variableName[variableName.startIndex]).uppercaseString)
        return "k\(className)\(variableName)Key"
    }
    
    class func checkType(value: JSON) -> String {
        var js : JSON = value as JSON
        var type: String = ""
        if let _ = js.string {
            type = "String"
        } else if let _ = js.number {
            type = "NSNumber"
        } else if let _ = js.bool {
            type = "Bool"
        } else if let _ = js.array {
            type = "[]"
        } else  {
            type = "AnyObject"
        }
        return type
    }
    
    public class func generate(anyObject: AnyObject, className: String, suffix: String?) {
        
        var declarations: String = ""
        var stringConstants: String = ""
        
        let parsedJSONObject = JSON(anyObject)
        let className = buildClassName(className, suffix: suffix!)
        if let object = parsedJSONObject.dictionary {
            for (key, subJson) in object {
                let variableName: String = variableNameBuilder(key)
                let stringConstantName: String = variableNameKeyBuilder(className, variableName: variableName)
                stringConstants = stringConstants.stringByAppendingFormat("\tinternal let %@: String = \"%@\"\n", stringConstantName, key)
                declarations = declarations.stringByAppendingFormat("\tvar %@: %@?\n", variableName, checkType(subJson))
            }
            
            print(stringConstants)
            print(declarations)
        }
    }
    
}
