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
    return String(self.prefix(1))
  }

  /**
   Makes the first character upper case.
   */
  mutating func uppercaseFirst() {
    self = first.uppercased() + String(self.dropFirst())
  }

  /**
   Makes the first character lowercase.
   */
  mutating func lowerCaseFirst() {
    self = first.lowercased() + String(self.dropFirst())
  }

  /**
   Replaces occurrence of multiple strings with a single string.

   - parameter strings:           String to replace.
   - parameter replacementString: String to replace with.
   */
  mutating func replaceOccurrencesOfStringsWithString(_ strings: [String], _ replacementString: String) {
    for string in strings {
      self = replacingOccurrences(of: string, with: replacementString)
    }
  }

  /**
   Removes whitespace and newline at the ends.
   */
  mutating func trim() {
    self = trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
  }

  /**
   Appends an optional to the string.

   - parameter prefix: String to append.
   */
  mutating func appendPrefix(_ prefix: String?) {
    if let _prefix = prefix {
      self = _prefix + self
    }
  }
}
