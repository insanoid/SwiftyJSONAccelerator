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
    case .string:
      return VariableType.string
    case .bool:
      return VariableType.bool
    case .array:
      return VariableType.array
    case .number:
      switch CFNumberGetType(self.numberValue as CFNumber) {
      case .sInt8Type,
          .sInt16Type,
          .sInt32Type,
          .sInt64Type,
          .charType,
          .shortType,
          .intType,
          .longType,
          .longLongType,
          .cfIndexType,
          .nsIntegerType:
          return VariableType.int
      case .float32Type,
          .float64Type,
          .floatType,
          .cgFloatType,
          .doubleType:
          return VariableType.float
      }
    case .null:
      return VariableType.null
    default:
      return VariableType.object
    }
  }
}
