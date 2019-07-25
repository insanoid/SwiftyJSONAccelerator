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
    static func loadFileWith(_ filename: String) -> String {
        let bundle = Bundle.main
        let path = bundle.path(forResource: filename, ofType: "txt")

        do {
            let content = try String(contentsOfFile: path!)
            return content
        } catch {}

        return ""
    }
}
