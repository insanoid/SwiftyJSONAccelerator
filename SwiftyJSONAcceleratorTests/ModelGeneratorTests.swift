//
//  ModelGeneratorTests.swift
//  SwiftyJSONAcceleratorTests
//
//  Created by Karthikeya Udupa on 03/08/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Foundation
import SwiftyJSON
import XCTest

class ModelGeneratorTests: XCTestCase {
    override func setUp() {
        super.setUp()
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
    }

    override func tearDown() {
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
        super.tearDown()
    }

    /// Generate a sample JSON class with all possible cases.
    ///
    /// - Returns: A valid JSON.
    func testJSON() -> JSON {
        return JSON(
            ["value_one": "string value",
             "value_two": 3,
             "value_three": true,
             "value_four": 3.4,
             "value_dont_show": JSON.null,
             "value_five": ["string", "random_stuff"],
             "value_six": ["sub_value": "value", "sub_value_second": false],
             "value_seven": [
                 [
                     "sub_value_third": 4.5,
                     "double_value": Double(5.3),
                     "sub_value_four": "value",
                     "internal": "renamed_value",
                     "sub_value_five": ["two_level_down": "value"]
                 ]
             ],
             "value_eight": []])
    }

    /// Default set of configuration that can be used for different cases
    ///
    /// - Parameter library: JSON Mapping method to be used.
    /// - Returns: Configuration with the default setup.
    func defaultConfiguration(library: JSONMappingMethod, optional: Bool) -> ModelGenerationConfiguration {
        return ModelGenerationConfiguration(
            filePath: "/tmp/",
            baseClassName: "BaseClass",
            authorName: "Jane Smith",
            companyName: "Acme Co.",
            prefix: "AC",
            constructType: .structType,
            modelMappingLibrary: library,
            separateCodingKeys: true,
            variablesOptional: optional,
            shouldGenerateInitMethod: true
        )
    }

    /// Test notification center local notifications - both successful and failure cases
    func testNotifications() {
        let config = defaultConfiguration(library: .swiftNormal, optional: false)
        let model = ModelGenerator(JSON([testJSON()]), config)
        let files = model.generate()
        let errorNotification = model.generateNotificationFor([])
        XCTAssertEqual(errorNotification.title!, "SwiftyJSONAccelerator")
        XCTAssertEqual(errorNotification.subtitle!, "No files were generated, cannot model arrays inside arrays.")

        let correctNotification = model.generateNotificationFor(files)
        XCTAssertEqual(correctNotification.title!, "SwiftyJSONAccelerator")
        XCTAssertEqual(correctNotification.subtitle!, "Completed - ACBaseClass.swift")
    }

    /// Test invalid JSON.
    func testForInvalidJSON() {
        let config = defaultConfiguration(library: .swiftNormal, optional: false)
        let model = ModelGenerator(JSON(["hello!"]), config)
        let files = model.generate()
        XCTAssert(files.isEmpty)
    }

    /// Generate files for JSON which is an array.
    func testModelWithRootAsArray() {
        let config = defaultConfiguration(library: .swiftNormal, optional: false)
        let model = ModelGenerator(JSON([testJSON()]), config)
        let files = model.generate()
        XCTAssert(files.count == 4)
        XCTAssertEqual(files.count, 4)

        var objectKey = "ValueSix"
        objectKey.appendPrefix(config.prefix)

        var subValueKey = "ValueSeven"
        subValueKey.appendPrefix(config.prefix)

        var objectArrayKey = "SubValueFive"
        objectArrayKey.appendPrefix(config.prefix)

        let possibleMathces = [objectKey, subValueKey, objectArrayKey]
        let fileNames = [files[3].fileName, files[2].fileName, files[1].fileName]
        for match in possibleMathces {
            XCTAssert(fileNames.contains(match))
        }

        let baseModelFile = files.first
        var baseClass = config.baseClassName
        baseClass.appendPrefix(config.prefix)
        XCTAssertEqual(baseModelFile!.fileName, baseClass)
    }

    func testModelGenerationConfiguration() {
        var modelConfig = ModelGenerationConfiguration(filePath: "A1", baseClassName: "A2",
                                                       authorName: "A3", companyName: "A4",
                                                       prefix: "A5", constructType: .classType,
                                                       modelMappingLibrary: .swiftCodeExtended,
                                                       separateCodingKeys: true, variablesOptional: true,
                                                       shouldGenerateInitMethod: true)

        XCTAssertEqual(modelConfig.filePath, "A1")
        XCTAssertEqual(modelConfig.baseClassName, "A2")
        XCTAssertEqual(modelConfig.authorName, "A3")
        XCTAssertEqual(modelConfig.companyName, "A4")
        XCTAssertEqual(modelConfig.prefix, "A5")
        XCTAssertEqual(modelConfig.constructType, .classType)
        XCTAssertEqual(modelConfig.modelMappingLibrary, .swiftCodeExtended)
        XCTAssertEqual(modelConfig.separateCodingKeys, true)
        XCTAssertEqual(modelConfig.variablesOptional, true)

        modelConfig.defaultConfig()

        XCTAssertEqual(modelConfig.filePath, "")
        XCTAssertEqual(modelConfig.baseClassName, "")
        XCTAssertEqual(modelConfig.prefix, "")
        XCTAssertEqual(modelConfig.constructType, .classType)
        XCTAssertEqual(modelConfig.modelMappingLibrary, .swiftNormal)
        XCTAssertEqual(modelConfig.separateCodingKeys, true)
        XCTAssertEqual(modelConfig.variablesOptional, true)
    }

    func testSwift5JSONModelsWithOptional() {
        let files = generateModelFiles(optional: true)
        testFileContent(files: files.0, optional: true, config: files.1)
    }

    func testSwift5JSONModelsWithNoOptionals() {
        let files = generateModelFiles(optional: false)
        testFileContent(files: files.0, optional: false, config: files.1)
    }

    func testFileContent(files: [ModelFile], optional: Bool, config: ModelGenerationConfiguration) {
        for file in files {
            validateDeclarations(filename: file.fileName, declarations: file.component.declarations, optional: optional)
            validateKeys(filename: file.fileName, stringKeys: file.component.stringConstants)
            validateInitialiser(filename: file.fileName, initialisers: file.component.initialisers, optional: optional)
            validateInitialiserFunctionComponents(filename: file.fileName, initialiserFunctionComponents: file.component.initialiserFunctionComponent, optional: optional)
            let content = FileGenerator.generateFileContentWith(file, configuration: config)
            let name = file.fileName
            let path = "/tmp/sj/"
            do {
                try FileGenerator.writeToFileWith(name, content: content, path: path)
            } catch {
                assertionFailure("File generation Failed")
            }
        }
    }

    func generateModelFiles(optional: Bool) -> ([ModelFile], ModelGenerationConfiguration) {
        let config = defaultConfiguration(library: .swiftNormal, optional: optional)
        let models = ModelGenerator(testJSON(), config)
        return (models.generate(), config)
    }

    func validateDeclarations(filename: String, declarations: [String], optional: Bool) {
        var possibleValues = ["ACBaseClass": ["var valueEight: Any?", "var valueTwo: Int?", "var valueThree: Bool?",
                                              "var valueSix: ACValueSix?", "var valueFour: Float?", "var valueOne: String?",
                                              "var valueFive: [String]?", "var valueSeven: [ACValueSeven]?"],
                              "ACValueSix": ["var subValue: String?", "var subValueSecond: Bool?"],
                              "ACValueSeven": ["var subValueFive: ACSubValueFive?", "var subValueFour: String?",
                                               "var internalProperty: String?", "var doubleValue: Float?",
                                               "var subValueThird: Float?"],
                              "ACSubValueFive": ["var twoLevelDown: String?"]]

        if optional == false {
            possibleValues = ["ACBaseClass": ["var valueEight: Any", "var valueTwo: Int", "var valueThree: Bool",
                                              "var valueSix: ACValueSix", "var valueFour: Float", "var valueOne: String",
                                              "var valueFive: [String]", "var valueSeven: [ACValueSeven]"],
                              "ACValueSix": ["var subValue: String", "var subValueSecond: Bool"],
                              "ACValueSeven": ["var subValueFive: ACSubValueFive", "var subValueFour: String",
                                               "var internalProperty: String", "var doubleValue: Float",
                                               "var subValueThird: Float"],
                              "ACSubValueFive": ["var twoLevelDown: String"]]
        }

        XCTAssertEqual(possibleValues[filename]?.count, declarations.count)
        for declaration in possibleValues[filename]! {
            XCTAssert(declarations.contains(declaration))
        }
    }

    func validateKeys(filename: String, stringKeys: [String]) {
        let possibleValues = ["ACBaseClass": ["case valueThree = \"value_three\"", "case valueSix = \"value_six\"", "case valueEight = \"value_eight\"", "case valueFive = \"value_five\"", "case valueFour = \"value_four\"", "case valueSeven = \"value_seven\"", "case valueOne = \"value_one\"", "case valueTwo = \"value_two\""],
                              "ACValueSix": ["case subValueSecond = \"sub_value_second\"", "case subValue = \"sub_value\""],
                              "ACValueSeven": ["case subValueFour = \"sub_value_four\"", "case subValueFive = \"sub_value_five\"", "case doubleValue = \"double_value\"", "case subValueThird = \"sub_value_third\"", "case internalProperty = \"internal\""],
                              "ACSubValueFive": ["case twoLevelDown = \"two_level_down\""]]
        XCTAssertEqual(possibleValues[filename]?.count, stringKeys.count)
        for stringKey in possibleValues[filename]! {
            XCTAssert(stringKeys.contains(stringKey))
        }
    }

    func validateInitialiser(filename: String, initialisers: [String], optional: Bool) {
        var possibleValues = ["ACBaseClass": ["valueOne = try container.decodeIfPresent(String.self, forKey: .valueOne)", "valueThree = try container.decodeIfPresent(Bool.self, forKey: .valueThree)", "valueSeven = try container.decodeIfPresent([ACValueSeven].self, forKey: .valueSeven)", "valueEight = try container.decodeIfPresent([].self, forKey: .valueEight)", "valueFour = try container.decodeIfPresent(Float.self, forKey: .valueFour)", "valueFive = try container.decodeIfPresent([String].self, forKey: .valueFive)", "valueSix = try container.decodeIfPresent(ACValueSix.self, forKey: .valueSix)", "valueTwo = try container.decodeIfPresent(Int.self, forKey: .valueTwo)"],
                              "ACValueSeven": ["subValueFive = try container.decodeIfPresent(ACSubValueFive.self, forKey: .subValueFive)", "doubleValue = try container.decodeIfPresent(Float.self, forKey: .doubleValue)", "subValueThird = try container.decodeIfPresent(Float.self, forKey: .subValueThird)", "internalProperty = try container.decodeIfPresent(String.self, forKey: .internalProperty)", "subValueFour = try container.decodeIfPresent(String.self, forKey: .subValueFour)"],
                              "ACSubValueFive": ["twoLevelDown = try container.decodeIfPresent(String.self, forKey: .twoLevelDown)"],
                              "ACValueSix": ["subValue = try container.decodeIfPresent(String.self, forKey: .subValue)", "subValueSecond = try container.decodeIfPresent(Bool.self, forKey: .subValueSecond)"]]

        if optional == false {
            possibleValues = ["ACBaseClass": ["valueSeven = try container.decode([ACValueSeven].self, forKey: .valueSeven)", "valueThree = try container.decode(Bool.self, forKey: .valueThree)", "valueFive = try container.decode([String].self, forKey: .valueFive)", "valueSix = try container.decode(ACValueSix.self, forKey: .valueSix)", "valueEight = try container.decode([].self, forKey: .valueEight)", "valueTwo = try container.decode(Int.self, forKey: .valueTwo)", "valueFour = try container.decode(Float.self, forKey: .valueFour)", "valueOne = try container.decode(String.self, forKey: .valueOne)"],
                              "ACValueSeven": ["subValueFive = try container.decode(ACSubValueFive.self, forKey: .subValueFive)", "subValueFour = try container.decode(String.self, forKey: .subValueFour)", "internalProperty = try container.decode(String.self, forKey: .internalProperty)", "subValueThird = try container.decode(Float.self, forKey: .subValueThird)", "doubleValue = try container.decode(Float.self, forKey: .doubleValue)"],
                              "ACSubValueFive": ["twoLevelDown = try container.decode(String.self, forKey: .twoLevelDown)"],
                              "ACValueSix": ["subValue = try container.decode(String.self, forKey: .subValue)", "subValueSecond = try container.decode(Bool.self, forKey: .subValueSecond)"]]
        }
        XCTAssertEqual(possibleValues[filename]?.count, initialisers.count)
        for initialiser in possibleValues[filename]! {
            XCTAssert(initialisers.contains(initialiser))
        }
    }

    func validateInitialiserFunctionComponents(filename: String, initialiserFunctionComponents: [InitialiserFunctionComponent], optional: Bool) {
        let possibleAssignmentValues = ["ACBaseClass": ["self.valueOne = valueOne", "self.valueThree = valueThree", "self.valueSeven = valueSeven", "self.valueEight = valueEight", "self.valueFour = valueFour", "self.valueFive = valueFive", "self.valueSix = valueSix", "self.valueTwo = valueTwo"],
                                        "ACValueSeven": ["self.subValueFive = subValueFive", "self.doubleValue = doubleValue", "self.subValueThird = subValueThird", "self.internalProperty = internalProperty", "self.subValueFour = subValueFour"],
                                        "ACSubValueFive": ["self.twoLevelDown = twoLevelDown"],
                                        "ACValueSix": ["self.subValue = subValue", "self.subValueSecond = subValueSecond"]]

        var possibleFunctionParamValues = ["ACBaseClass": ["valueSeven: [ACValueSeven]", "valueThree: Bool", "valueFive: [String]", "valueSix: ACValueSix", "valueEight: Any", "valueTwo: Int", "valueFour: Float", "valueOne: String"],
                                           "ACValueSeven": ["subValueFive: ACSubValueFive", "subValueFour: String", "internalProperty: String", "subValueThird: Float", "doubleValue: Float"],
                                           "ACSubValueFive": ["twoLevelDown: String"],
                                           "ACValueSix": ["subValue: String", "subValueSecond: Bool"]]

        if optional == true {
            possibleFunctionParamValues = ["ACBaseClass": ["valueSeven: [ACValueSeven]?", "valueThree: Bool?", "valueFive: [String]?", "valueSix: ACValueSix?", "valueEight: Any?", "valueTwo: Int?", "valueFour: Float?", "valueOne: String?"],
                                           "ACValueSeven": ["subValueFive: ACSubValueFive?", "subValueFour: String?", "internalProperty: String?", "subValueThird: Float?", "doubleValue: Float?"],
                                           "ACSubValueFive": ["twoLevelDown: String?"],
                                           "ACValueSix": ["subValue: String?", "subValueSecond: Bool?"]]
        }

        XCTAssertEqual(possibleAssignmentValues[filename]?.count, initialiserFunctionComponents.count)
        XCTAssertEqual(possibleFunctionParamValues[filename]?.count, initialiserFunctionComponents.count)
        for initialiserFunctionComponent in initialiserFunctionComponents {
            XCTAssert(possibleAssignmentValues[filename]!.contains(initialiserFunctionComponent.assignmentString))
            XCTAssert(possibleFunctionParamValues[filename]!.contains(initialiserFunctionComponent.functionParameter))
        }
    }

    func testClassModelGenerator() {
        var config = defaultConfiguration(library: .swiftNormal, optional: true)
        config.constructType = .classType
        let models = ModelGenerator(testJSON(), config)
        let files = models.generate()

        for file in files {
            let content = FileGenerator.generateFileContentWith(file, configuration: config)
            XCTAssert(content.contains("  required init(from decoder: Decoder) throws {"))
        }
    }
}
