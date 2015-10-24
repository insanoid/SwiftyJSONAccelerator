//
//  SJModelGenerator.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 20/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Foundation
import Cocoa

/**
*  Internal Structure for storing the types of variables.
*  - kStringType
*  - kNumberType
*  - kBoolType
*  - kArrayType
*  - kObjectType
*/
struct VariableType {
    static let kStringType: String = "String"
    static let kNumberType = "NSNumber"
    static let kBoolType = "Bool"
    static let kArrayType = "[]"
    static let kObjectType = "{OBJ}"
}

/**
*  Types of models that can be generated.
*  - kClassType: Class type
*  - kStructType: Struct type
*/
public struct ModelType {
    static let kClassType: String = "class"
    static let kStructType: String = "struct"
}

/// Model generator responsible for creation of models based on the JSON, needs to be initalized with all properties before proceeding.
public class ModelGenerator {

    //MARK: Variables
    var authorName: String?
    var companyName: String?
    var prefix: String?
    var baseContent: JSON
    var type: String
    var filePath: String
    var baseClassName: String


    /**
    Initalize the model generator with various settings.

    - parameter baseContent:   Base JSON that has to be converted into model.
    - parameter prefix:        Prefix for the class.
    - parameter baseClassName: Name of the base class.
    - parameter authorName:    Name of the author, for use in the header documentation of the file.
    - parameter companyName:   Name of the company, for use in the header documentation of the file.
    - parameter type:          Type of the model that has to be generated, Struct or Class.
    - parameter filePath:      Filepath where the generated model has to be saved.

    - returns: A ModelGenerator instance.
    */
    init(baseContent: JSON, prefix: String?, baseClassName: String, authorName: String?, companyName: String?, type: String, filePath: String) {
        self.authorName = authorName
        self.baseContent = baseContent
        self.prefix = prefix
        self.authorName = authorName != nil ? authorName : NSFullUserName()
        self.companyName = companyName
        self.type = type
        self.filePath = filePath
        self.baseClassName = baseClassName
    }

    /**
    Generate the model files, ensure init has set all the required properties before calling this.
    */
    public func generate() {

        // Generate the model and get the name of the class.
        let name: String = generateModelForClass(baseContent, className: baseClassName, isSubModule: false)

        // Notify user that the files are generated!
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "SwiftyJSONAccelerator"
        if name.characters.count > 0 {
            notification.subtitle = "Completed - \(name).swift"
        } else {
            notification.subtitle = "No files were generated, cannot model arrays inside arrays."
        }
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }

    //MARK: Internal methods

    /**
    Generates model for the given class name and the content, this is called recursively to handle nested objects.

    - parameter parsedJSONObject: JSON which has to be converted into the model.
    - parameter className:        Name of the class.

    - returns: Returns the final name of the class.
    */
    internal func generateModelForClass(parsedJSONObject: JSON, className: String, isSubModule: Bool) -> String {

        /// Initalize values that will be populated for each of the variables.
        var declarations: String = ""
        var stringConstants: String = ""
        var initalizers: String = ""
        var encoders: String = ""
        var decoders: String = ""
        var description: String = ""

        /// Create a classname in Sentence case and removing unwanted stuff.
        let className = buildClassName(className, prefix: self.prefix!, isSubModule: isSubModule)

        if let object = parsedJSONObject.dictionary {

            for (key, jsonValue) in object {

                let variableName: String = variableNameBuilder(key)
                let stringConstantName: String = variableNameKeyBuilder(className, variableName: variableName)
                let variableType: String = checkType(jsonValue)

                // The key declaration and the encoder is same for all kinds of objects.
                stringConstants = stringConstants.stringByAppendingFormat(stringConstantDeclrationBuilder(stringConstantName, key: key))
                encoders = encoders.stringByAppendingFormat("%@\n", encoderForVariable(variableName, key: stringConstantName, type: variableType))


                // If the content is an array, we have to handle the elements and decide what to do.
                if variableType == VariableType.kArrayType {

                    // If the array has objects, then take the first one and proces it to generate a model.
                    if jsonValue.arrayValue.count > 0 {

                        // TODO: Instead of taking a single element consider merging all the elements and decide what to do as a while.
                        let subClassType = checkType(jsonValue.arrayValue[0])

                        // If the type is an object, generate a new model and also create appropriate initalizers, declarations and decoders.
                        if subClassType == VariableType.kObjectType {
                            let subClassName = generateModelForClass(jsonValue.arrayValue[0], className: variableName, isSubModule:true)
                            declarations = declarations.stringByAppendingFormat(variableDeclarationBuilder(variableName, type: "[\(subClassName)]"))
                            initalizers = initalizers.stringByAppendingFormat("%@\n", initalizerForObjectArray(variableName, className: subClassName, key: stringConstantName))
                            decoders = decoders.stringByAppendingFormat("%@\n", decoderForVariable(variableName,key: stringConstantName, type: "[\(subClassName)]"))
                            description = description.stringByAppendingFormat("%@\n", descriptionForObjectArray(variableName, key: stringConstantName))
                        } else {
                            // If it is anything other than an object, it should be a primitive type hence deal with it accordingly.
                            declarations = declarations.stringByAppendingFormat(variableDeclarationBuilder(variableName, type: "[\(subClassType)]"))
                            initalizers = initalizers.stringByAppendingFormat("%@\n", initalizerForPrimitiveVariableArray(variableName, key: stringConstantName, type: subClassType))
                            decoders = decoders.stringByAppendingFormat("%@\n", decoderForVariable(variableName,key: stringConstantName, type: "[\(subClassType)]"))
                            description = description.stringByAppendingFormat("%@\n", descriptionForPrimitiveVariableArray(variableName, key: stringConstantName))
                        }
                        // TODO: We should also consider a third case where the type is an [AnyObject] to achive complete redundancy handling.

                    } else {

                        // if nothing is there make it a blank array.
                        // TODO: Maybe handle blank array a bit better.
                        declarations = declarations.stringByAppendingFormat(variableDeclarationBuilder(variableName, type: variableType))
                        initalizers = initalizers.stringByAppendingFormat("%@\n", initalizerForEmptyArray(variableName, key: stringConstantName))

                    }

                } else if variableType == VariableType.kObjectType {
                    // If variable is a kind of object, generate a new model for it and set appropriate initalizers, declarations and decoders.
                    let subClassName = generateModelForClass(jsonValue, className: variableName, isSubModule:true)
                    declarations = declarations.stringByAppendingFormat(variableDeclarationBuilder(variableName, type: subClassName))
                    initalizers = initalizers.stringByAppendingFormat("%@\n", initalizerForObject(variableName, className: subClassName, key: stringConstantName))
                    decoders = decoders.stringByAppendingFormat("%@\n", decoderForVariable(variableName,key: stringConstantName, type: subClassName))
                    description = description.stringByAppendingFormat("%@\n", descriptionForObjectVariableArray(variableName, key: stringConstantName))

                } else {
                    // If it is a primitive then simply create initalizers, declarations and decoders.
                    declarations = declarations.stringByAppendingFormat(variableDeclarationBuilder(variableName, type: variableType))
                    initalizers = initalizers.stringByAppendingFormat("%@\n", initalizerForVariable(variableName, type: variableType, key: stringConstantName))
                    decoders = decoders.stringByAppendingFormat("%@\n", decoderForVariable(variableName,key: stringConstantName, type: variableType))
                    description = description.stringByAppendingFormat("%@\n", descriptionForVariable(variableName, key: stringConstantName))
                }

            }

            // Get an instance of the template.
            var content: String = templateContent()

            // Replace all the generated properties in the appropriated placeholders in the template.
            content = content.stringByReplacingOccurrencesOfString("{OBJECT_NAME}", withString: className)
            content = content.stringByReplacingOccurrencesOfString("{DATE}", withString: todayDateString())
            content = content.stringByReplacingOccurrencesOfString("{OBJECT_KIND}", withString: type)
            content = content.stringByReplacingOccurrencesOfString("{STRING_CONSTANT_BLOCK}", withString: stringConstants)
            content = content.stringByReplacingOccurrencesOfString("{PROPERTIES}", withString: declarations)
            content = content.stringByReplacingOccurrencesOfString("{INITALIZER}", withString: initalizers)
            content = content.stringByReplacingOccurrencesOfString("{ENCODERS}", withString: encoders)
            content = content.stringByReplacingOccurrencesOfString("{DECODERS}", withString: decoders)
            content = content.stringByReplacingOccurrencesOfString("{DESC}", withString: description)

            if authorName != nil {
                content = content.stringByReplacingOccurrencesOfString("__NAME__", withString: authorName!)
            }
            if companyName != nil {
                content = content.stringByReplacingOccurrencesOfString("__MyCompanyName__", withString: companyName!)
            }

            // Write everything to the file at the path.
            writeToFile(className, content: content, path: filePath)

        }  else if let object = parsedJSONObject.array {
            // Incase the first object was NOT a dictionary.
            // TODO: Instead of taking a single element consider merging all the elements and decide what to do as a while.
            let subClassType = checkType(object[0])

            // If the type is an object then make it the base class and generate stuff.
            if subClassType == VariableType.kObjectType {
                self.generateModelForClass(object[0], className: className, isSubModule: false)
            }
            return ""
        }

        return className
    }


    //MARK: Generators for names of classes, variables and types.

    /**
    Generates a classname based on the string and suffix e.g. "KT"+"ClassNameSentenceCase", also replaces _.

    - parameter className: Name of the class, will be converted to Sentence case.
    - parameter suffix:    Suffix that has to be appendend to the class.

    - returns: A generated string representing the name of the class in the model.
    */
    internal func buildClassName(className: String, prefix: String, isSubModule: Bool)  -> String {

        // If it is a submodule it is already formatted no need to camelcase it.
        var classNameCleaned = isSubModule ? className : variableNameBuilder(className)
        classNameCleaned.replaceRange(classNameCleaned.startIndex...classNameCleaned.startIndex, with: String(classNameCleaned[classNameCleaned.startIndex]).uppercaseString)
        return prefix.stringByAppendingString(classNameCleaned)
    }

    /**
    Generate a variable name in sentence case with the first letter as lowercase, also replaces _. Ensures all caps are maintained if previously set in the name.

    - parameter variableName: Name of the variable in the JSON

    - returns: A generated string representation of the variable name.
    */
    internal func variableNameBuilder(variableName: String) -> String {
        let variableName = replaceInternalKeywordsForVariableName(variableName).stringByReplacingOccurrencesOfString("_", withString: " ")
        var finalVariableName: String = ""
        for (index, element) in variableName.componentsSeparatedByString(" ").enumerate() {
            var component: String = element
            if index != 0 {
                component.replaceRange(component.startIndex...component.startIndex, with: String(component[component.startIndex]).uppercaseString)
            }
            finalVariableName.appendContentsOf(component)
        }
        return finalVariableName

    }

    /**
    Generate a variable name to store the key of the variable in the JSON for later use (generating JSON file, encoding and decoding). the format is k{ClassName}{VariableName}Key.

    - parameter className:    Name of the class where this variable is.  (Already formatted)
    - parameter variableName: Name of the variable (Already formatted)

    - returns: A generated string that can be used to store the key of the variable in the JSON.
    */
    internal func variableNameKeyBuilder(className: String, var variableName: String) -> String {
        variableName.replaceRange(variableName.startIndex...variableName.startIndex, with: String(variableName[variableName.startIndex]).uppercaseString)
        return "k\(className)\(variableName)Key"
    }

    /**
    Declaration of the variable for the key that is to be used for encoding, decoding and reading from json.
    internal let {constantName}: String = {key}

    - parameter constantName: Constant name.
    - parameter key:          Key that is used in the JSON.

    - returns: A generated string declaring the string constant for the key.
    */
    internal func stringConstantDeclrationBuilder(constantName: String, key: String) -> String {
        return "\tinternal let \(constantName): String = \"\(key)\"\n"
    }


    /**
    The declaration for the variable of the class. public var {variableName}: {type}?

    - parameter variableName: Variable name.
    - parameter type:         Type of the variable.

    - returns: A generated string for declaring the variable.
    */
    internal func variableDeclarationBuilder(variableName: String, type: String) -> String {
        return "\tpublic var \(variableName): \(type)?\n"
    }



    /**
    Check the type of the variable by assesing the value, if it is not any of the known type mark it as an object.

    - parameter value: Value that is stored against a particular key in the JSON.

    - returns: Type of the variable.
    */
    internal func checkType(value: JSON) -> String {

        var js : JSON = value as JSON
        var type: String = VariableType.kObjectType

        if let _ = js.string {
            type = VariableType.kStringType
        } else if let _ = js.number {
            type = VariableType.kNumberType
        } else if let _ = js.bool {
            type = VariableType.kBoolType
        } else if let _ = js.array {
            type = VariableType.kArrayType
        }

        return type
    }


    /**
    Initialization of the variable "if let value = json[{key}].{type} { variableName = value }"
    - parameter variableName: Variable name.
    - parameter type:         Type of the variable.
    - parameter key:          Key against which the value is stored.

    - returns: A single line declaration of the variable.
    */
    internal func initalizerForVariable(variableName: String, var type: String, key: String) -> String {
        type = typeToSwiftType(type)
        return "\t\tif let tempValue = json[\(key)].\(type) {\n\t\t\t\(variableName) = tempValue\n\t\t}"
    }

    /**
    Initalizer for an Object kind of variable.
    - parameter variableName: Variable name.
    - parameter className:    Name of the Class of the object.
    - parameter key:          Key against which the value is stored.
    - returns: A single line declaration of the variable.
    */
    internal func initalizerForObject(variableName: String, className: String, key: String) -> String {
        return  "\t\t\(variableName) = \(className)(json: json[\(key)])"
    }

    /**
    Initalizer for an Empty array kind of variable.
    - parameter variableName: Variable name.
    - parameter key:          Key against which the value is stored.
    - returns: A single line declaration of the variable.
    */
    internal func initalizerForEmptyArray(variableName: String, key: String) -> String {
        return "\t\tif let tempValue = json[\(key)].array {\n\t\t\t\(variableName) = tempValue\n\t\t}"
    }

    /**
    Initalizer for an Object kind of array variable.
    - parameter variableName: Variable name.
    - parameter className:    Name of the Class of the object.
    - parameter key:          Key against which the value is stored.
    - returns: A single line declaration of the variable which is an array of object.
    */
    internal func initalizerForObjectArray(variableName: String, className: String, key: String) -> String {
        return  "\t\t\(variableName) = []\n\t\tif let items = json[\(key)].array {\n\t\t\tfor item in items {\n\t\t\t\t\(variableName)?.append(\(className)(json: item))\n\t\t\t}\n\t\t}\n"
    }

    /**
    Initalizer for an primitive kind of elements array variable.
    - parameter variableName: Variable name.
    - parameter key:          Key against which the value is stored.
    - returns: A single line declaration of the variable which is an array of primitive kind.
    */
    internal func initalizerForPrimitiveVariableArray(variableName: String, key: String, var type: String) -> String {
        type = typeToSwiftType(type)
        return  "\t\t\(variableName) = []\n\t\tif let items = json[\(key)].array {\n\t\t\tfor item in items {\n\t\t\t\tif let tempValue = item.\(type) {\n\t\t\t\t\(variableName)?.append(tempValue)\n\t\t\t\t}\n\t\t\t}\n\t\t}\n"
    }

    /**
    Encoder for a variable.
    - parameter variableName: Variable name.
    - parameter key:          Key against which the value is stored.
    - returns: A single line encoder of the variable.
    */
    internal func encoderForVariable(variableName: String, key: String, type: String) -> String {
        if type == VariableType.kBoolType {
            return "\t\taCoder.encodeBool(\(variableName), forKey: \(key))"
        }
        return "\t\taCoder.encodeObject(\(variableName), forKey: \(key))"
    }
    /**
    Decoder for a variable.
    - parameter variableName: Variable name.
    - parameter key:          Key against which the value is stored.
    - returns: A single line decoder of the variable.
    */
    internal func decoderForVariable(variableName: String, key: String, type: String) -> String {
        if type == VariableType.kBoolType {
            return "\t\tself.\(variableName) = aDecoder.decodeBoolForKey(\(key))"
        }
        return "\t\tself.\(variableName) = aDecoder.decodeObjectForKey(\(key)) as? \(type)"
    }

    /**
    Initialization of the variable "if let value = json[{key}].{type} { variableName = value }"
    - parameter variableName: Variable name.
    - parameter type:         Type of the variable.
    - parameter key:          Key against which the value is stored.

    - returns: A single line declaration of the variable.
    */
    internal func initalize(variableName: String, var type: String, key: String) -> String {
        type = typeToSwiftType(type)
        return "\t\tif let tempValue = json[\(key)].\(type) {\n\t\t\t\(variableName) = tempValue\n\t\t}"
    }

    /**
    Description of the variable if {variableName} != nil { dictionary.updateValue({variableName}!, forKey: {key})
    }
    - parameter variableName: Variable name.
    - parameter type:         Type of the variable.
    - parameter key:          Key against which the value is stored.

    - returns: A single line description printer of the variable.
    */
    internal func descriptionForVariable(variableName: String, key: String) -> String {
        return "\t\tif \(variableName) != nil {\n\t\t\tdictionary.updateValue(\(variableName)!, forKey: \(key))\n\t\t}"
    }

    /**
    Description for an Object kind of an array variable. if {variableName}?.count > 0 { var temp: [AnyObject] = [] for item in {variableName}! { temp.append(item.dictionaryRepresentation()) } dictionary.updateValue(temp, forKey: {key}) }
    }
    - parameter variableName: Variable name.
    - parameter className:    Name of the Class of the object.
    - parameter key:          Key against which the value is stored.
    - returns: A single line declaration of the variable which is an array of object.
    */
    internal func descriptionForObjectArray(variableName: String, key: String) -> String {
        return  "\t\tif \(variableName)?.count > 0 {\n\t\t\tvar temp: [AnyObject] = []\n\t\t\tfor item in \(variableName)! {\n\t\t\t\ttemp.append(item.dictionaryRepresentation())\n\t\t\t}\n\t\t\tdictionary.updateValue(temp, forKey: \(key))\n\t\t}"
    }

    /**
    Description for an Object kind of a primitive variable. if {variableName}?.count > 0 { dictionary.updateValue({variableName}!, forKey: {key})
    - parameter variableName: Variable name.
    - parameter key:          Key against which the value is stored.
    - returns: A single line declaration of the variable which is an array of primitive kind.
    */
    internal func descriptionForPrimitiveVariableArray(variableName: String, key: String) -> String {
        return "\t\tif \(variableName)?.count > 0 {\n\t\t\tdictionary.updateValue(\(variableName)!, forKey: \(key))\n\t\t}"
    }

    /**
    Description for an Object kind of AnyObject. if {variableName}?.count > 0 { dictionary.updateValue({variableName}!.dictionaryRepresentation(), forKey: {key})
    - parameter variableName: Variable name.
    - parameter key:          Key against which the value is stored.
    - returns: A single line declaration of the variable which is an array of primitive kind.
    */
    internal func descriptionForObjectVariableArray(variableName: String, key: String) -> String {
        return "\t\tif \(variableName) != nil {\n\t\t\tdictionary.updateValue(\(variableName)!.dictionaryRepresentation(), forKey: \(key))\n\t\t}"
    }

    /**
    Generates the string for today's date.

    - returns: A string date in dd/MM/yyyy.
    */
    internal func todayDateString() -> String {
        let formatter = NSDateFormatter.init()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.stringFromDate(NSDate.init())
    }

    /**
    Fetch the template for creating model.swift files.

    - returns: String containing the template.
    */
    internal func templateContent() -> String {

        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("BaseTemplate", ofType: "txt")

        do {

            let content = try String.init(contentsOfFile: path!)
            return content

        } catch {

        }

        return ""
    }

    /**
    Write the given content to a file named as the className at the mentioned path.

    - parameter className: Classname which is also the name of the file.
    - parameter content:   Content that has to be written on the file.
    - parameter path:      Path where the file has to be created.
    */
    internal func writeToFile(className: String, content: String, path: String) {
        let filename = path.stringByAppendingFormat("/%@",(className.stringByAppendingString(".swift")))
        do {
            try content.writeToFile(filename, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            print(filename)
        }
    }
    
    /**
    Generates a swift variable type from the given VariableType.
    
    - parameter type: VariableType
    - returns: swift variable type.
    */
    internal func typeToSwiftType(var type: String) -> String {
        if type == VariableType.kNumberType {
            type = "number"
        } else {
            type.replaceRange(type.startIndex...type.startIndex, with: String(type[type.startIndex]).lowercaseString)
        }
        
        return type
    }


    /**
    Cross checks the list of internal variables against the current variables and repalces them based on the mapping.

    - parameter currentName: Current name of the variable.

    - returns: New name for the variable.
    */
    internal func replaceInternalKeywordsForVariableName(currentName: String) -> String {

        let currentReservedName = ["id":"internalIdentifier","description":"descriptionValue","_id":"internalIdentifier"]
        for (key, value) in currentReservedName {
            if key == currentName {
                return value
            }
        }
        return currentName

    }
    
}
