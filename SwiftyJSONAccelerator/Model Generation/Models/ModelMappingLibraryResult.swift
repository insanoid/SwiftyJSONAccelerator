//
//  ModelMappingLibraryResult.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 01/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

/**
 *  A structure to store result from model mapping library.
 */
struct ModelMappingLibraryResult {

  /// Module name that has to be included.
  let moduleName: String
  /// Initialiser method that has to be injected into init.
  let initialiserCode: String

  /**
   Initialise the struct with the information.

   - parameter moduleName:      Module name that has to be included.
   - parameter initialiserCode: Initialisation code that converts JSON to properties.

   - returns: Instance of the results.
   */
  init(_ moduleName: String, _ initialiserCode: String) {
    self.moduleName = moduleName
    self.initialiserCode = initialiserCode
  }
}
