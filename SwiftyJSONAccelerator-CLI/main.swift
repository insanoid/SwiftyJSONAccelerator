//
//  main.swift
//  SwiftyJSONAccelerator-CLI
//
//  Created by Karthik on 26/12/2016.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

CLI.setup(name: "swiftyjsonaccelerator", version: "1.4.0", description: "Create swift models from JSON files")
var path = FileManager.default.currentDirectoryPath
CLI.registerChainableCommand(name: "generate")
    .withOptionsSetup({ (options) in
        options.add(keys: ["-p", "--path"], usage: "Provide a path else takes the path of execution.") { (value) in
            path = value
        }
    })
    .withExecutionBlock { (arguments) in
        print("Generating Models from JSON at: " + path)
        do {
            let generatedModelInfo = try MultipleModelGenerator.generate(forPath: path)
            for file in generatedModelInfo.modelFiles {
                let content = FileGenerator.generateFileContentWith(file, configuration: generatedModelInfo.configuration)
                let name = file.fileName
                print(" ✓   " + name)
                try FileGenerator.writeToFileWith(name, content: content, path: generatedModelInfo.configuration.filePath)
            }
            print("✓ Generation Complete - \(generatedModelInfo.modelFiles.count) files at \(generatedModelInfo.configuration.filePath)")
        } catch let error as MultipleModelGeneratorError {
            throw CLIError.error("✖ Error: Unable to generate the files." + "\n✖ Reason: " + error.errorMessage())
        } catch let error as NSError {
            throw CLIError.error("✖ Error: Unable to generate the files." + "\n✖ Reason: " + error.localizedDescription)
        }
}
let result = CLI.go()
exit(result)
