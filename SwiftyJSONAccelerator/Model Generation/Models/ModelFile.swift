//
//  ModelFile.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 01/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

/**
 *  A struct to store information about the model that was generated.
 */
struct ModelFile {

    /// Filename for the model.
    let fileName: String
    /// Content that has to be stored in the model.
    let content: String
}