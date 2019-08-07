//
//  FileGenerator.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 09/07/2016.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

struct FileGenerator {
    /// Fetch the template for creating model.swift files.
    ///
    /// - Parameter filename: Name of the file to be loaded
    /// - Returns: String containing the template.
    static func loadFileWith(_ filename: String) throws -> String {
        let bundle = Bundle.main
        guard let path = bundle.path(forResource: filename, ofType: "txt") else {
            return ""
        }
        let content = try String(contentsOfFile: path)
        return content
    }
}
