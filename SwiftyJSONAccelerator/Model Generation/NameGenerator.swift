//
//  NameGenerator.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 01/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

struct NameGenerator {

    /**
     Generates/fixes a classname based on the string and suffix e.g. "KT"+"ClassNameSentenceCase".
     Replaces invalid characters.

     - parameter className: Name of the class, will be converted to sentence case.
     - parameter suffix:    Suffix that has to be appended to the class.

     - returns: A generated string representing the name of the class in the model.
     */
    static func fixClassName(className: String, _ prefix: String?, _ isTopLevelObject: Bool) -> String {

        // If it is not a top level object, it is already formatted (since it is a property)
        var formattedClassName = isTopLevelObject ? fixVariableName(className) : className
        formattedClassName.uppercaseFirst()
        formattedClassName.appendPrefix(prefix)
        return formattedClassName
    }

    /**
     Generates/fixes a variable name in sentence case with the first letter as lowercase.
     Replaces invalid names and swift keywords.
     Ensures all caps are maintained if previously set in the name.

     -parameter variableName: Name of the variable in the JSON

     - returns: A generated string representation of the variable name.
     */
    static func fixVariableName(variableName: String) -> String {

        var _variableName = replaceKeywords(variableName)
        _variableName.replaceOccurrencesOfStringsWithString(["-", "_"], " ")
        _variableName.trim()

        var finalVariableName = ""
        for (index, var element) in variableName.componentsSeparatedByString(" ").enumerate() {
            index == 0 ? element.lowerCaseFirst() : element.uppercaseFirst()
            finalVariableName.appendContentsOf(element)
        }
        return finalVariableName

    }

    /**
     Cross checks the current name against a possible set of keywords, this list is no where
     extensive, but it is not meant to be, user should be able to do this in the unlikely case it happens.

     - returns: New name for the variable.
     */
    static func replaceKeywords(currentName: String) -> String {

        let keywordsWithReplacements = ["id": "internalIdentifier",
            "description": "descriptionValue",
            "_id": "internalIdentifier",
            "class": "classProperty",
            "struct": "structProperty",
            "enum": "enumProperty",
            "internal": "internalProperty"]
        if let value = keywordsWithReplacements[currentName] {
            return value
        }
        return currentName
    }

}
