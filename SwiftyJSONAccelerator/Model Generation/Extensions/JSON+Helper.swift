//
//  JSON+Helper.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 01/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

// Helper methods for JSON.
extension JSON {

    /**
     Extensive value types with differentiation between the number types.

     - returns: Value type of the JSON value
     */
    func detailedValueType() -> VariableType {
        switch self.type {
        case .String:
            return VariableType.String
        case .Bool:
            return VariableType.Bool
        case .Array:
            return VariableType.Array
        case .Number:
            switch CFNumberGetType(self.numberValue as CFNumberRef) {
            case .SInt8Type, .SInt16Type, .SInt32Type, .SInt64Type, .CharType, .ShortType, .IntType, .LongType, .LongLongType, .CFIndexType, .NSIntegerType:
                return VariableType.Int
            case .Float32Type, .Float64Type, .FloatType, .CGFloatType:
                return VariableType.Float
            case .DoubleType:
                return VariableType.Double
            }
        default:
            return VariableType.Object
        }
    }
}

// Helper for Array of JSON.
extension Array where Element: JSON {

    /**
     Reduces an array of JSON to a single JSON with all possible keys.

     - returns: Reduced JSON with the common key/value pairs.
     */
    func reduce() -> JSON {
        var finalObject: JSON = JSON([:])
        for item in self {
            for (key, jsonValue) in item {
                if finalObject[key] == nil {
                    finalObject[key] = jsonValue
                } else if let newValue = jsonValue.dictionary {
                    finalObject[key] = mergeArrayToSingleObject([JSON(newValue), finalObject[key]])
                } else if let newValue = jsonValue.array {
                    finalObject[key] = JSON([mergeArrayToSingleObject(newValue + finalObject[key].arrayValue)])
                }
            }
        }
        return finalObject
    }

}