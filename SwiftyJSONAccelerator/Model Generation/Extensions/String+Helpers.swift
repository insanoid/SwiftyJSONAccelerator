//
//  String+Helpers.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 01/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

// Extension for string to provide helper method to generate names.
extension String {

  /// Fetches the first character of the string.
  var first: String {
    return String(characters.prefix(1))
  }

  /**
   Makes the first character upper case.
   */
  mutating func uppercaseFirst() {
    self = first.uppercaseString + String(characters.dropFirst())
  }

  /**
   Makes the first character lowercase.
   */
  mutating func lowerCaseFirst() {
    self = first.lowercaseString + String(characters.dropFirst())
  }

  /**
   Replaces occurrence of multiple strings with a single string.

   - parameter strings:           String to replace.
   - parameter replacementString: String to replace with.
   */
  mutating func replaceOccurrencesOfStringsWithString(strings: [String], _ replacementString: String) {
    for string in strings {
      self = stringByReplacingOccurrencesOfString(string, withString: replacementString)
    }
  }

  /**
   Removes whitespace and newline at the ends.
   */
  mutating func trim() {
    self = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
  }

  /**
   Appends an optional to the string.

   - parameter prefix: String to append.
   */
  mutating func appendPrefix(prefix: String?) {
    if let _prefix = prefix {
      appendContentsOf(_prefix)
    }
  }
}
