//
//  ModelGenerationConfiguration.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 01/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

/**
 *  Structure to store the configuration for the model generation.
 */
struct ModelGenerationConfiguration {
  /// Path where the generated files have to be stored.
  var filePath: String
  /// Name of the root level class for the provided JSON.
  var baseClassName: String
  /// The author name that has to be put in the file's header comments.
  var authorName: String?
  /// Company name that has to be put into the file's header.
  var companyName: String?
  /// A namespace prefix for the file (not recommended for Swift but people might want it)
  var prefix: String?
  /// Type of the object that have to be generated.
  var constructType: ConstructType
  /// Model mapping library to be used.
  var modelMappingLibrary: JSONMappingLibrary
  /// Include NSCodingSupport/Currently only works for Classes.
  var supportNSCoding: Bool
}
