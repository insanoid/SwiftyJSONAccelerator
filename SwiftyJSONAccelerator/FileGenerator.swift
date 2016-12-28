//
//  FileGenerator.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 09/07/2016.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

struct FileGenerator {

    /**
   Fetch the template for creating model.swift files.

   - parameter filename: Name of the file to be loaded

   - returns: String containing the template.
   */
    static func loadFileWith(_ filename: String) -> String {

        let bundle = Bundle.main
        let path = bundle.path(forResource: filename, ofType: "txt")

        do {
            let content = try String.init(contentsOfFile: path!)
            return content
        } catch { }

        return ""
    }
}
