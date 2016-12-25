//
//  SJSONCLI.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 22/12/2016.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

class SJA {
    func staticMode() {
        ConsoleIO.printUsage()
    }
    /*
    -   Step I: Read arugments.
        -   If argument has a config file use it to pre fill arugments required.
        -   If the folder contains a config file use it.
        -   if arugments are not all met, use defaults, if no defaults throw error for argument.
    -   Step II: Process JSON Files.
        -   Does the folder contain .json files, if not throw error.
        -   Go through JSON file and convert it into JSON objects in code, if it fails, throw error.
     -  Step III: Generate Models and Reduce.
        -   Pass every JSON file and get the `ModelFile`.
        -   Reduce the model file; Go through the duplicate models, merge them into one single model, else have a fallback plan.
     -  Step 4: Save
        -   Once everything is done, save it in the given directory.
     */
}
