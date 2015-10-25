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
    static let kIntNumberType = "Int"
    static let kFloatNumberType = "Float"
    static let kDoubleNumberType = "Double"
    static let kCGFloatNumberType = "CGFloat"
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
    
    var supportSwiftyJSON: Bool
    var includeSwiftyJSON: Bool
    
    var supportObjectMapper: Bool
    var includeObjectMapper: Bool
    
    var supportNSCoding: Bool


    /**
     Initalize the model generator with various settings.

     - parameter baseContent:   Base JSON that has to be converted into model.
     - parameter prefix:        Prefix for the class.
     - parameter baseClassName: Name of the base class.
     - parameter authorName:    Name of the author, for use in the header documentation of the file.
     - parameter companyName:   Name of the company, for use in the header documentation of the file.
     - parameter type:          Type of the model that has to be generated, Struct or Class.
     - parameter filePath:      Filepath where the generated model has to be saved.
     - parameter includeSwiftyJSON:  Boolean indicating if the header should have SwiftyJSON

     - returns: A ModelGenerator instance.
     */
    init(baseContent: JSON, prefix: String?, baseClassName: String, authorName: String?, companyName: String?, type: String, filePath: String, supportSwiftyJSON: Bool, includeSwiftyJSON: Bool, supportObjectMapper: Bool, includeObjectMapper: Bool, supportNSCoding: Bool) {
        self.authorName = authorName
        self.baseContent = baseContent
        self.prefix = prefix
        self.authorName = authorName != nil ? authorName : NSFullUserName()
        self.companyName = companyName
        self.type = type
        self.filePath = filePath
        self.baseClassName = baseClassName
        self.supportSwiftyJSON = supportSwiftyJSON
        self.includeSwiftyJSON = includeSwiftyJSON
        self.supportNSCoding = supportNSCoding
        self.supportObjectMapper = supportObjectMapper
        self.includeObjectMapper = includeObjectMapper
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
        var objectMapperMappings: String = ""
        
        var objectBaseClass = "NSObject"

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

                        let subClassType = checkType(jsonValue.arrayValue[0])

                        // If the type is an object, generate a new model and also create appropriate initalizers, declarations and decoders.
                        if subClassType == VariableType.kObjectType {
                            let subClassName = generateModelForClass(mergeArrayToSingleObject(jsonValue.arrayValue), className: variableName, isSubModule:true)
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

                //ObjectMapper is generic for all
                objectMapperMappings = objectMapperMappings.stringByAppendingFormat("%@\n", mappingForObjectMapper(variableName, key:stringConstantName))
            }

            // Get an instance of the template.
            var content: String = templateContent()

            // Replace all the generated properties in the appropriated placeholders in the template.
            content = content.stringByReplacingOccurrencesOfString("{OBJECT_NAME}", withString: className)
            content = content.stringByReplacingOccurrencesOfString("{DATE}", withString: todayDateString())
            content = content.stringByReplacingOccurrencesOfString("{OBJECT_KIND}", withString: type)
            content = content.stringByReplacingOccurrencesOfString("{STRING_CONSTANT_BLOCK}", withString: stringConstants)
            content = content.stringByReplacingOccurrencesOfString("{PROPERTIES}", withString: declarations)
            
            if self.supportNSCoding
            {
                content = content.stringByReplacingOccurrencesOfString("{NSCODING_PROTOCOL_SUPPORT}", withString: ", NSCoding")
                content = content.stringByReplacingOccurrencesOfString("{NSCODING_SUPPORT}", withString: "\t// MARK: NSCoding Protocol\n\trequired public init(coder aDecoder: NSCoder) {\n\t{DECODERS}\n\t}\n\n\tpublic func encodeWithCoder(aCoder: NSCoder) {\n{ENCODERS}\n\t}")

                content = content.stringByReplacingOccurrencesOfString("{ENCODERS}", withString: encoders)
                content = content.stringByReplacingOccurrencesOfString("{DECODERS}", withString: decoders)
            }
            else
            {
                content = content.stringByReplacingOccurrencesOfString("{NSCODING_PROTOCOL_SUPPORT}", withString: "")
                content = content.stringByReplacingOccurrencesOfString("{NSCODING_SUPPORT}", withString: "")
            }
            
            if self.supportSwiftyJSON
            {
                if let swiftyBase = try? String(contentsOfFile: NSBundle.mainBundle().pathForResource("SwiftyJSONTemplate", ofType: "txt")!)
                {
                    content = content.stringByReplacingOccurrencesOfString("{SWIFTY_JSON_SUPPORT}", withString: swiftyBase)

                    content = content.stringByReplacingOccurrencesOfString("{INITALIZER}", withString: initalizers)

                    if includeSwiftyJSON {
                        content = content.stringByReplacingOccurrencesOfString("{INCLUDE_SWIFTY}", withString: "\nimport SwiftyJSON")
                    } else {
                        content = content.stringByReplacingOccurrencesOfString("{INCLUDE_SWIFTY}", withString: "")
                    }
                }
                else
                {
                    content = content.stringByReplacingOccurrencesOfString("{SWIFTY_JSON_SUPPORT}", withString: "")
                    content = content.stringByReplacingOccurrencesOfString("{INCLUDE_SWIFTY}", withString: "")
                }
            }
            else
            {
                content = content.stringByReplacingOccurrencesOfString("{SWIFTY_JSON_SUPPORT}", withString: "")
                content = content.stringByReplacingOccurrencesOfString("{INCLUDE_SWIFTY}", withString: "")
            }
            
            if self.supportObjectMapper
            {
                if let objectMapperBase = try? String(contentsOfFile: NSBundle.mainBundle().pathForResource("ObjectMapperTemplate", ofType: "txt")!)
                {
                    content = content.stringByReplacingOccurrencesOfString("{OBJECT_MAPPER_SUPPORT}", withString: objectMapperBase)
                    
                    content = content.stringByReplacingOccurrencesOfString("{OBJECT_MAPPER_INITIALIZER}", withString: objectMapperMappings)
                    
                    objectBaseClass = "Mappable"
                    
                    if includeObjectMapper {
                        content = content.stringByReplacingOccurrencesOfString("{INCLUDE_OBJECT_MAPPER}", withString: "\nimport ObjectMapper")
                    } else {
                        content = content.stringByReplacingOccurrencesOfString("{INCLUDE_OBJECT_MAPPER}", withString: "")
                    }
                }
                else
                {
                    content = content.stringByReplacingOccurrencesOfString("{OBJECT_MAPPER_SUPPORT}", withString: "")
                    content = content.stringByReplacingOccurrencesOfString("{INCLUDE_OBJECT_MAPPER}", withString: "")
                }
            }
            else
            {
                content = content.stringByReplacingOccurrencesOfString("{OBJECT_MAPPER_SUPPORT}", withString: "")
                content = content.stringByReplacingOccurrencesOfString("{INCLUDE_OBJECT_MAPPER}", withString: "")
            }

            content = content.stringByReplacingOccurrencesOfString("{DESC}", withString: description)

            if authorName != nil {
                content = content.stringByReplacingOccurrencesOfString("__NAME__", withString: authorName!)
            }
            if companyName != nil {
                content = content.stringByReplacingOccurrencesOfString("__MyCompanyName__", withString: companyName!)
            }

            content = content.stringByReplacingOccurrencesOfString("{OBJECT_BASE_CLASS}", withString: objectBaseClass)
            


            // Write everything to the file at the path.
            writeToFile(className, content: content, path: filePath)

        }  else if let object = parsedJSONObject.array {
            // Incase the first object was NOT a dictionary.
            let subClassType = checkType(object[0])

            // If the type is an object then make it the base class and generate stuff.
            if subClassType == VariableType.kObjectType {
                return self.generateModelForClass(mergeArrayToSingleObject(object), className: className, isSubModule: false)
            } else {
                return ""
            }
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
        
        //We can be smarter about numbers. Rather than toss all numbers to NSNumber, we'll detect the internal type and use a simplified version of that.
        
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
        } else if let _ = js.bool {
            type = VariableType.kBoolType
        } else if let validNumber = js.number {
            
            //Smarter number type detection. Rather than use generic NSNumber, we can use a specific type. These are grouped into the common Swift number types.
            let numberRef = CFNumberGetType(validNumber as CFNumberRef)
            
            switch numberRef {
                
            case .SInt8Type:
                fallthrough
            case .SInt16Type:
                fallthrough
            case .SInt32Type:
                fallthrough
            case .SInt64Type:
                fallthrough
            case .CharType:
                fallthrough
            case .ShortType:
                fallthrough
            case .IntType:
                fallthrough
            case .LongType:
                fallthrough
            case .LongLongType:
                fallthrough
            case .CFIndexType:
                fallthrough
            case .NSIntegerType:
                type = VariableType.kIntNumberType
                
            case .Float32Type:
                fallthrough
            case.Float64Type:
                fallthrough
            case .FloatType:
                type = VariableType.kFloatNumberType
                
            case .DoubleType:
                type = VariableType.kDoubleNumberType
                
            case .CGFloatType:
                type = VariableType.kCGFloatNumberType
            }
            
        } else if let _ = js.array {
            type = VariableType.kArrayType
        }

        return type
    }

    /**
     A mapping for the variable for use with ObjectMapper
     - parameter variableName: Variable name.
     - parameter key:          Key against which the value is stored.
     
     - returns: A single line mapping for the variable
     */
    internal func mappingForObjectMapper(variableName: String, key: String) -> String {
        return "\t\t\(variableName) <- map[\"\(key)\"]\n"
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
        return "\t\t\(variableName) = json[\(key)].\(type)\n"
    }

    /**
     Initalizer for an Object kind of variable.
     - parameter variableName: Variable name.
     - parameter className:    Name of the Class of the object.
     - parameter key:          Key against which the value is stored.
     - returns: A single line declaration of the variable.
     */
    internal func initalizerForObject(variableName: String, className: String, key: String) -> String {
        return  "\t\t\(variableName) = \(className)(json: json[\(key)])\n"
    }

    /**
     Initalizer for an Empty array kind of variable.
     - parameter variableName: Variable name.
     - parameter key:          Key against which the value is stored.
     - returns: A single line declaration of the variable.
     */
    internal func initalizerForEmptyArray(variableName: String, key: String) -> String {
        return "\t\tif let tempValue = json[\(key)].array {\n\t\t\t\(variableName) = tempValue\n\t\t} else {\n\t\t\t\(variableName) = nil\n\t\t}\n"
    }

    /**
     Initalizer for an Object kind of array variable.
     - parameter variableName: Variable name.
     - parameter className:    Name of the Class of the object.
     - parameter key:          Key against which the value is stored.
     - returns: A single line declaration of the variable which is an array of object.
     */
    internal func initalizerForObjectArray(variableName: String, className: String, key: String) -> String {
        return  "\t\t\(variableName) = []\n\t\tif let items = json[\(key)].array {\n\t\t\tfor item in items {\n\t\t\t\t\(variableName)?.append(\(className)(json: item))\n\t\t\t}\n\t\t} else {\n\t\t\t\(variableName) = nil\n\t\t}\n"
    }

    /**
     Initalizer for an primitive kind of elements array variable.
     - parameter variableName: Variable name.
     - parameter key:          Key against which the value is stored.
     - returns: A single line declaration of the variable which is an array of primitive kind.
     */
    internal func initalizerForPrimitiveVariableArray(variableName: String, key: String, var type: String) -> String {
        type = typeToSwiftType(type)
        return  "\t\t\(variableName) = []\n\t\tif let items = json[\(key)].array {\n\t\t\tfor item in items {\n\t\t\t\tif let tempValue = item.\(type) {\n\t\t\t\t\(variableName)?.append(tempValue)\n\t\t\t\t}\n\t\t\t}\n\t\t} else {\n\t\t\t\(variableName) = nil\n\t\t}\n"
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
        return "\t\t\(variableName) = json[\(key)].\(type)\n"
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
        
        let isNumber = (type == VariableType.kIntNumberType || type == VariableType.kFloatNumberType || type == VariableType.kCGFloatNumberType || type == VariableType.kDoubleNumberType)
        
        if isNumber {
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

        let currentReservedName = ["id" : "internalIdentifier", "description" : "descriptionValue","_id" : "internalIdentifier","class" : "classProperty", "struct" : "structProperty", "internal" : "internalProperty"]
        for (key, value) in currentReservedName {
            if key == currentName {
                return value
            }
        }
        return currentName

    }

    /**
     Merge Array of objects into a single object containing all the possible combinations of objects. Deals only with homogeneous objects.
     
     - parameter items: Array of objects that have to be merged into a single one.
     
     - returns: JSON containing a combination of all the properties in the array.
     */
    internal func mergeArrayToSingleObject(items: [JSON]) -> JSON {
        var finalObject: JSON = JSON([ : ])
        for item in items {
            for (key, jsonValue) in item {
                if finalObject[key] == nil {
                    finalObject[key] = jsonValue
                } else if let newValue = jsonValue.dictionary {
                    finalObject[key] = mergeArrayToSingleObject([JSON(newValue), finalObject[key]])
                } else if let newValue = jsonValue.array {
                    finalObject[key] = JSON([mergeArrayToSingleObject(newValue +  finalObject[key].arrayValue)])
                }
            }
        }
        return finalObject
    }
    
}
