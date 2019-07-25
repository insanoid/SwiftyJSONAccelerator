//
//  String+Helpers.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 01/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

// Extension for string to provide helper method to generate names.
public extension String {
    /// Fetches the first character of the string.
    var firstChar: String {
        return String(self.prefix(1))
    }

    /// Makes the first character of the string uppercase.
    mutating func uppercaseFirst() {
        self = firstChar.uppercased() + String(dropFirst())
    }

    /// Makes the first character of the string lowercase.
    mutating func lowercaseFirst() {
        self = firstChar.lowercased() + String(dropFirst())
    }

    /// Replace occurrence of multiple strings with a single string.
    ///
    /// - Parameters:
    ///   - strings: String to replace.
    ///   - replacementString: String to replace with.
    mutating func replaceOccurrencesOfStringsWithString(_ strings: [String], _ replacementString: String) {
        for string in strings {
            self = replacingOccurrences(of: string, with: replacementString)
        }
    }

    /// Removes whitespace and newline at the ends.
    mutating func trim() {
        self = trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    /// Appends an optional to the string.
    ///
    /// - Parameter prefix: String to append.
    mutating func appendPrefix(_ prefix: String?) {
        if let _prefix = prefix {
            self = _prefix + self
        }
    }

    func characterRowAndLineAt(position: Int)
        -> (character: String, line: Int, column: Int) {
        var lineNumber = 0
        var characterPosition = 0
        for line in components(separatedBy: "\n") {
            lineNumber += 1
            var columnNumber = 0
            // TODO: Check this.
            for column in line {
                characterPosition += 1
                columnNumber += 1
                if characterPosition == position {
                    return (String(column), lineNumber, columnNumber)
                }
            }
            characterPosition += 1
            if characterPosition == position {
                return ("\n", lineNumber, columnNumber + 1)
            }
        }
        return ("", 0, 0)
    }
}
