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
    /// Indicates if the final keyword is required for the object.
    var isFinalRequired: Bool
    /// Should header be included.
    var isHeaderIncluded: Bool

    /// Checks if the configuration is valid as per the rules of Swift.
    ///
    /// - Returns: If the config is valid and the reason for invalidation if it is invalid.
    func isConfigurationValid() -> (isValid: Bool, reason: String) {
        if constructType == .structType && (isFinalRequired == true || supportNSCoding == true) {
            return (false, "Struct cannot have final or NSCoding support, only applicable to class.")
        }
        return (true, "")
    }

    mutating func defaultConfig() {
        isHeaderIncluded = true
        isFinalRequired = true
        supportNSCoding = true
        modelMappingLibrary = .libSwiftyJSON
        constructType = .classType
        prefix = ""
        filePath = ""
        baseClassName = ""
    }

}
