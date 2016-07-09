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
    case .String:
      return VariableType.String
    case .Bool:
      return VariableType.Bool
    case .Array:
      return VariableType.Array
    case .Number:
      switch CFNumberGetType(self.numberValue as CFNumberRef) {
      case .SInt8Type,
          .SInt16Type,
          .SInt32Type,
          .SInt64Type,
          .CharType,
          .ShortType,
          .IntType,
          .LongType,
          .LongLongType,
          .CFIndexType,
          .NSIntegerType:
          return VariableType.Int
      case .Float32Type,
          .Float64Type,
          .FloatType,
          .CGFloatType,
          .DoubleType:
          return VariableType.Float
      }
    case .Null:
      return VariableType.Null
    default:
      return VariableType.Object
    }
  }
}
