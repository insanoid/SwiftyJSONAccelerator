//
//  SJModelGenerator.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 20/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Foundation
import Cocoa

struct VariableType {
    static let kStringType: String = "String"
    static let kNumberType = "NSNumber"
    static let kBoolType = "Bool"
    static let kArrayType = "[]"
    static let kObjectType = "{OBJ}"
}

/// Model generator responsible for creation of models based on the JSON, needs to be initalized with all properties before proceeding.
public class ModelGenerator {
    
    var authorName: String?
    var companyName: String?
    var prefix: String?
    var baseContent: JSON
    var type: String
    var filePath: String
    var baseClassName: String
    
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
        
        let name: String = generateModelForClass(baseContent, className: baseClassName)
        
        // Notify user that the files are generated!
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "SwiftyJSONAccelerator"
        notification.subtitle = "Complete!"
        notification.informativeText = "Generated \(name).swift along with modules!"
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        
    }
    
    //MARK: Internal methods
    
    /**
    Generates model for the given class name and the content, this is called recursively to handle nested objects.
    
    - parameter parsedJSONObject: JSON which has to be converted into the model.
    - parameter className:        Name of the class.
    
    - returns: Returns the final name of the class.
    */
    internal func generateModelForClass(parsedJSONObject: JSON, className: String) -> String {
        
        var declarations: String = ""
        var stringConstants: String = ""
        var initalizers: String = ""
        var encoders: String = ""
        var decoders: String = ""
        
        let className = buildClassName(className, prefix: self.prefix!)
        if let object = parsedJSONObject.dictionary {
            for (key, subJson) in object {
                
                let variableName: String = variableNameBuilder(key)
                let stringConstantName: String = variableNameKeyBuilder(className, variableName: variableName)
                let variableType: String = checkType(subJson)
                
                stringConstants = stringConstants.stringByAppendingFormat(stringConstantDeclrationBuilder(stringConstantName, key: key))
                encoders = encoders.stringByAppendingFormat("%@\n", encoderForVariable(variableName, key: stringConstantName, type: variableType))
                
                if variableType == VariableType.kArrayType {
                    
                    // If the array has objects, then take the first one and proces it to generate a model.
                    if subJson.arrayValue.count > 0 {
                        let subClassName = generateModelForClass(subJson.arrayValue[0], className: variableName)
                        declarations = declarations.stringByAppendingFormat(variableDeclarationBuilder(variableName, type: "[\(subClassName)]"))
                        initalizers = initalizers.stringByAppendingFormat("%@\n", initalizerForObjectArray(variableName, className: subClassName, key: stringConstantName))
                        decoders = decoders.stringByAppendingFormat("%@\n", decoderForVariable(variableName,key: stringConstantName, type: "[\(subClassName)]"))
                    } else {
                        // if nothing is there make it a blank array.
                        declarations = declarations.stringByAppendingFormat(variableDeclarationBuilder(variableName, type: variableType))
                        initalizers = initalizers.stringByAppendingFormat("%@\n", initalizerForEmptyArray(variableName, key: stringConstantName))
                        
                    }
                    
                } else if variableType == VariableType.kObjectType {
                    
                    let subClassName = generateModelForClass(subJson, className: variableName)
                    declarations = declarations.stringByAppendingFormat(variableDeclarationBuilder(variableName, type: subClassName))
                    initalizers = initalizers.stringByAppendingFormat("%@\n", initalizerForObject(variableName, className: subClassName, key: stringConstantName))
                    decoders = decoders.stringByAppendingFormat("%@\n", decoderForVariable(variableName,key: stringConstantName, type: subClassName))
                    
                } else {
                    
                    declarations = declarations.stringByAppendingFormat(variableDeclarationBuilder(variableName, type: variableType))
                    initalizers = initalizers.stringByAppendingFormat("%@\n", initalizerForVariable(variableName, type: variableType, key: stringConstantName))
                    decoders = decoders.stringByAppendingFormat("%@\n", decoderForVariable(variableName,key: stringConstantName, type: variableType))
                    
                }
                
            }
            
            
            var content: String = templateContent()
            
            content = content.stringByReplacingOccurrencesOfString("{OBJECT_NAME}", withString: className)
            content = content.stringByReplacingOccurrencesOfString("{DATE}", withString: todayDateString())
            
            if authorName != nil {
                content = content.stringByReplacingOccurrencesOfString("__NAME__", withString: authorName!)
            }
            if companyName != nil {
                content = content.stringByReplacingOccurrencesOfString("__MyCompanyName__", withString: companyName!)
            }
            
            content = content.stringByReplacingOccurrencesOfString("{OBJECT_KIND}", withString: type)
            content = content.stringByReplacingOccurrencesOfString("{STRING_CONSTANT_BLOCK}", withString: stringConstants)
            content = content.stringByReplacingOccurrencesOfString("{PROPERTIES}", withString: declarations)
            content = content.stringByReplacingOccurrencesOfString("{INITALIZER}", withString: initalizers)
            content = content.stringByReplacingOccurrencesOfString("{ENCODERS}", withString: encoders)
            content = content.stringByReplacingOccurrencesOfString("{DECODERS}", withString: decoders)
            
            writeToFile(className, content: content, path: filePath)
            
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
    internal func buildClassName(className: String, prefix: String)  -> String {
        var classNameCleaned = variableNameBuilder(className)
        classNameCleaned.replaceRange(classNameCleaned.startIndex...classNameCleaned.startIndex, with: String(classNameCleaned[classNameCleaned.startIndex]).uppercaseString)
        return prefix.stringByAppendingString(classNameCleaned)
    }
    
    /**
    Generate a variable name in sentence case with the first letter as lowercase, also replaces _.
    
    - parameter variableName: Name of the variable in the JSON
    
    - returns: A generated string representation of the variable name.
    */
    internal func variableNameBuilder(variableName: String) -> String {
        var variableName = variableName.stringByReplacingOccurrencesOfString("_", withString: " ")
        variableName = variableName.capitalizedString
        variableName = variableName.stringByReplacingOccurrencesOfString(" ", withString: "")
        variableName.replaceRange(variableName.startIndex...variableName.startIndex, with: String(variableName[variableName.startIndex]).lowercaseString)
        return variableName
        
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
    
    internal func stringConstantDeclrationBuilder(constantName: String, key: String) -> String {
        return "\tinternal let \(constantName): String = \"\(key)\"\n"
    }
    
    internal func variableDeclarationBuilder(variableName: String, type: String) -> String {
        return "\tvar \(variableName): \(type)?\n"
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
    
    
    internal func initalizerForVariable(variableName: String, var type: String, key: String) -> String {
        if type == VariableType.kNumberType {
            type = "number"
        } else {
            type.replaceRange(type.startIndex...type.startIndex, with: String(type[type.startIndex]).lowercaseString)
        }
        return "\t\tif let value = json[\(key)].\(type) {\n\t\t\t\(variableName) = value\n\t\t}"
    }
    
    internal func initalizerForObject(variableName: String, className: String, key: String) -> String {
        return  "\t\t\(variableName) = \(className)(json: json[\(key)])"
    }
    
    internal func initalizerForEmptyArray(variableName: String, key: String) -> String {
        return "\t\tif let value = json[\(key)].array {\n\t\t\t\(variableName) = value\n\t\t}"
    }
    
    internal func initalizerForObjectArray(variableName: String, className: String, key: String) -> String {
        return  "\t\t\(variableName) = []\n\t\tif let items = json[\(key)].array {\n\t\t\tfor item in items {\n\t\t\t\t\(variableName)?.append(\(className)(json: item))\n\t\t\t}\n\t\t}\n"
    }
    
    internal func encoderForVariable(variableName: String, key: String, type: String) -> String {
        if type == VariableType.kBoolType {
            return "\t\taCoder.encodeBool(\(variableName), forKey: \(key))"
        }
         return "\t\taCoder.encodeObject(\(variableName), forKey: \(key))"
    }
    
    internal func decoderForVariable(variableName: String, key: String, type: String) -> String {
        if type == VariableType.kBoolType {
            return "\t\tself.\(variableName) = aDecoder.decodeBoolForKey(\(key))"
        }
        return "\t\tself.\(variableName) = aDecoder.decodeObjectForKey(\(key)) as? \(type)"
    }
    
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
    
    /*
    required init(coder aDecoder: NSCoder) {
    self.bottlesArray = aDecoder.decodeObjectForKey("bottleArray") as NSMutableArray
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(bottlesArray, forKey: "bottleArray")
    }
*/

    
}
