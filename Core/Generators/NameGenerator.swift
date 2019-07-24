//
//  NameGenerator.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 01/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

/**
 *  A structure to store the various kinds of string name generation functions for classes and variables.
 */
struct NameGenerator {

  /**
   Generates/fixes a classname based on the string and suffix e.g. "KT"+"ClassNameSentenceCase".
   Replaces invalid characters.

   - parameter className: Name of the class, will be converted to sentence case.
   - parameter prefix:    Suffix that has to be appended to the class.
   - parameter isTopLevelObject: Indicates if the object is the root of the JSON.

   - returns: A generated string representing the name of the class in the model.
   */
  static func fixClassName(_ className: String, _ prefix: String?, _ isTopLevelObject: Bool)
    -> String {

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

   - parameter variableName: Name of the variable in the JSON

   - returns: A generated string representation of the variable name.
   */
  static func fixVariableName(_ variableName: String) -> String {

    var tmpVariableName = replaceKeywords(variableName)
    tmpVariableName.replaceOccurrencesOfStringsWithString(["-", "_"], " ")
    tmpVariableName.trim()

    var finalVariableName = ""
    for (index, var element) in tmpVariableName.components(separatedBy: " ").enumerated() {
      index == 0 ? element.lowerCaseFirst() : element.uppercaseFirst()
      finalVariableName.append(element)
    }
    return finalVariableName

  }

  /**
   Cross checks the current name against a possible set of keywords, this list is no where
   extensive, but it is not meant to be, user should be able to do this in the unlikely
   case it happens.

   - parameter currentName: The current name which has to be checked.

   - returns: New name for the variable.
   */
  static func replaceKeywords(_ currentName: String) -> String {

    let keywordsWithReplacements = [
      "description": "descriptionValue",
      "class": "classProperty",
      "struct": "structProperty",
      "enum": "enumProperty",
      "internal": "internalProperty",
      "default": "defaultValue"]
    if let value = keywordsWithReplacements[currentName] {
      return value
    }
    return currentName
  }

  /**
   Generate the key for the given variable.

   - parameter className:    Name of the class.
   - parameter variableName: Name of the Varible.

   - returns: The name for the key for the variable in the given class.
   */
  static func variableKey(_ className: String, _ variableName: String) -> String {
    return "SerializationKeys.\(variableName)"
  }
}
