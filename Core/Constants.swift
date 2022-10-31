//
//  Constants.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 24/07/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Foundation

/// Various supported variable types
enum VariableType: String {
    case string = "String"
    case int = "Int"
    case float = "Float"
    case double = "Double"
    case bool = "Bool"
    case array = "[]"
    case object = "{OBJ}"
    case null = "Any"
}

/// Various types of construct that can be generated.
///
/// - classType:  Model with construct type class.
/// - structType: Model with construct type struct.
enum ConstructType: String {
    case classType = "class"
    case structType = "struct"
}

/// Various types of access control modifiers that can be applied to objects and properties.
enum AccessControl: String, CaseIterable {
    case `internal`
    case `private`
    case `public`

    /// The prefix to be applied to objects and properties' declarations.
    var declarationPrefix: String {
        switch self {
        case .internal:
            // The default access control type, no need to explicitly set it
            return ""
        default:
            return rawValue
        }
    }
}

/// JSON mapping options available in the UI
///
/// - Swift: Pure Swift 5 Codeable
/// - SwiftCodeExtended: Codeextended along with Swift 5 - https://github.com/JohnSundell/Codextended
enum JSONMappingMethod: String {
    case swiftNormal = "swiftCodingVanilla"
    case swiftCodeExtended
}

/// Types of property.
///
/// - Value: Value type like String, Integer, Float etc.
/// - ValueArray: Array of Value
/// - Object: Object type
/// - ObjectArray: Array of object
/// - emptyArray: An empty array
/// - Null: Null value
enum PropertyType: String {
    case valueType
    case valueTypeArray
    case objectType
    case objectTypeArray
    case emptyArray
    case nullType
}

/// Place to store actual constants that don't fit in classes.
enum Constants {
    static let filePathKey: String = "path"
}
