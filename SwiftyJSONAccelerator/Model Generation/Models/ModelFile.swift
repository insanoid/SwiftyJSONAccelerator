//
//  ModelFile.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 01/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

/**
 *  A protocol defining the structure of the model file.
 */
protocol ModelFile {

    /// Filename for the model.
    var fileName: String { get set }
    var type: ConstructType { get set }
    var declarations: [String] { get }
    var stringConstants: [String] { get }
    var initialisers: [String] { get }
    var encoders: [String] { get }
    var decoders: [String] { get }
    var description: [String] { get }

    init(fileName: String, _ configuration: ModelGenerationConfiguration)

    func addStringConstant(constantName: String, _ value: String)
    func addEncoder(name: String, _ type: String, _ constantName: String)

    func addDecoder(name: String, _ type: String, _ constantName: String)
    func addInitialiser(name: String, _ type: String, _ constantName: String)
    func addDescription(name: String, _ type: String, _ constantName: String)
    func addDeclaration(name: String, _ type: String, _ constantName: String)

    func addBasicInfo(name: String, _ type: String, _ constantName: String)
    /*
     currentModel.addInitialiser(variableName, name!, stringConstantName)
     currentModel.addDescription(variableName, name!, stringConstantName)
     currentModel.addDecoder(variableName, name!, stringConstantName)
     currentModel.addDescription(variableName, name!, stringConstantName)
     * */

    func generateModel() -> String
    func moduleName() -> String

}