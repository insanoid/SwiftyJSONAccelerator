//
//  JSON+Helper.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 01/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation
import SwiftyJSON

// Helper methods for JSON.
extension JSON {

  /**
   Extensive value types with differentiation between the number types.

   - returns: Value type of the JSON value
   */
  func detailedValueType() -> VariableType {
    switch self.type {
    case .string:
      return VariableType.String
    case .bool:
      return VariableType.Bool
    case .array:
      return VariableType.Array
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
          return VariableType.Int
      case .float32Type,
          .float64Type,
          .floatType,
          .cgFloatType,
          .doubleType:
          return VariableType.Float
      }
    case .null:
      return VariableType.Null
    default:
      return VariableType.Object
    }
  }
}
