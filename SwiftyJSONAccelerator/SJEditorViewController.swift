//
//  SJEditorViewController.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 16/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Cocoa

/// View for the processing of the content and generation of the files.
class SJEditorViewController: NSViewController, NSTextViewDelegate {

    // MARK: Outlet files.
    @IBOutlet var textView: SJTextView!
    @IBOutlet var messageLabel: NSTextField!
    @IBOutlet var errorImageView: NSImageView!
    @IBOutlet var baseClassTextField: NSTextField!
    @IBOutlet var prefixClassTextField: NSTextField!
    @IBOutlet var companyNameTextField: NSTextField!
    @IBOutlet var authorNameTextField: NSTextField!
    @IBOutlet var includeSwiftyCheckbox: NSButton!
    @IBOutlet var supportNSCodingCheckbox: NSButton!
    @IBOutlet var supportSwiftyJSONCheckbox: NSButton!
    @IBOutlet var supportObjectMapperCheckbox: NSButton!
    @IBOutlet var includeObjectMapperCheckbox: NSButton!

    // MARK: View methods
    override func loadView() {
        super.loadView()
        textView!.delegate = self
        textView!.updateFormat()
        textView!.lnv_setUpLineNumberView()
        resetErrorImage()
        authorNameTextField?.stringValue = NSFullUserName()
    }

    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    // MARK: Actions
    @IBAction func format(sender: AnyObject?) {
        if validateAndFormat(true) {
            generateModel()
        }

    }

    /**
     Validates and updates the textview.

     - parameter pretty: If the JSON is to be pretty printed.

     - returns: if the format was valid.
     */
    func validateAndFormat(pretty: Bool) -> Bool {

        if textView?.string?.characters.count == 0 {
            return false
        }

        textView!.updateFormat()
        if let (valid, error): (Bool, NSError?) = JSONHelper.isStringValidJSON(textView?.string) {
            if valid {
                if pretty {
                    textView?.string = JSONHelper.prettyJSON(textView?.string)!
                    textView!.lnv_textDidChange(NSNotification.init(name: NSTextDidChangeNotification, object: nil))
                    return true
                }
                correctJSONMessage()
            } else if error != nil {
                handleError(error)
                textView!.lnv_textDidChange(NSNotification.init(name: NSTextDidChangeNotification, object: nil))
                return false
            }
        }
        return false
    }

    /**
     Actual function that generates the model.
     */
    func generateModel() {

        // The base class field is blank, cannot proceed without it. Possibly can have a default value in the future.
        if  baseClassTextField?.stringValue.characters.count <= 0 {
            let alert:NSAlert = NSAlert()
            alert.messageText = "Enter a base class name to continue."
            alert.runModal()
            return
        }

        let filePath: String? = openFile()

        // No file path was selected, go back!
        if filePath == nil {
            return
        }

        let object: AnyObject? = JSONHelper.convertToObject(textView?.string).1

        // Checks for validity of the content, else can cause crashes.
        if object != nil {

            let swiftyState = self.includeSwiftyCheckbox?.state == 1 ? true : false
            let supportSwiftyState = self.supportSwiftyJSONCheckbox?.state == 1 ? true : false

            let nscodingState = self.supportNSCodingCheckbox?.state == 1 ? true : false

            let objectMapperState = self.includeObjectMapperCheckbox?.state == 1 ? true : false
            let supportObjectMapperState = self.supportObjectMapperCheckbox?.state == 1 ? true : false

            let generator: ModelGenerator = ModelGenerator(baseContent: JSON(object!), baseClassName: baseClassTextField.stringValue, filePath: filePath!)

            generator.prefix = prefixClassTextField.stringValue
            generator.authorName = authorNameTextField.stringValue
            generator.companyName = companyNameTextField.stringValue
            generator.type = ModelType.kClassType
            generator.supportSwiftyJSON = supportSwiftyState
            generator.includeSwiftyJSON = swiftyState
            generator.supportObjectMapper = supportObjectMapperState
            generator.includeObjectMapper = objectMapperState
            generator.supportNSCoding = nscodingState

            generator.generate()
        } else {
            let alert:NSAlert = NSAlert()
            alert.messageText = "Unable to save the file check the content."
            alert.runModal()
        }
    }

    @IBAction func recalcEnabledBoxes(sender: AnyObject) {

        let supportSwiftyState = self.supportSwiftyJSONCheckbox?.state == 1 ? true : false
        let supportObjectMapperState = self.supportObjectMapperCheckbox?.state == 1 ? true : false

        if supportSwiftyState {
            self.includeSwiftyCheckbox?.enabled = true
        }
        else {
            self.includeSwiftyCheckbox?.enabled = false
        }

        if supportObjectMapperState {
            self.includeObjectMapperCheckbox?.enabled = true
        }
        else {
            self.includeObjectMapperCheckbox?.enabled = false
        }
    }

    // MARK: Internal Methods

    /**
    Get the line number, column and the character for the position in the given string.

    - parameters:
    - string: The JSON string that is in the textview.
    - position: the location where the error is.

    - returns:
    - character: the string that was causing the issue.
    - line: the linenumber where the error was.
    - column: the column where the error was.
    */
    func characterRowAndLineAt(string: String,position: Int) -> (character: String, line: Int, column:Int) {
        var lineNumber = 0
        var characterPosition = 0
        for line in string.componentsSeparatedByString("\n") {
            lineNumber += 1
            var columnNumber = 0
            for column in line.characters {
                characterPosition += 1
                columnNumber += 1
                if characterPosition == position {
                    return (String(column), lineNumber, columnNumber )
                }
            }
            characterPosition += 1
            if characterPosition == position {
                return ("\n", lineNumber, columnNumber+1 )
            }
        }
        return ("", 0,0)
    }

    /**
     Handle Error message that is provided by the JSON helper and extract the message and showing them accordingly.

     - parameters:
     - error: NSError that was provided.
     */
    func handleError(error: NSError?) {
        if let _ = error!.userInfo["debugDescription"] as? String? {
            let message: String = error!.userInfo["NSDebugDescription"]! as! String
            let numbers: [String] = message.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)

            var validNumbers:[Int] = []
            for number in numbers where (Int(number) != nil) {
                validNumbers.append(Int(number)!)
            }

            if validNumbers.count == 1 {
                let index:Int = validNumbers[0]
                let errorPosition: (character: String, line: Int, column:Int) = characterRowAndLineAt((textView?.string)!, position: index)
                let customErrorMessage = "Error at line number: \(errorPosition.line) column: \(errorPosition.column) at Character: \(errorPosition.character)."
                invalidJSONError(customErrorMessage)
            } else {
                invalidJSONError(message)
            }
        }
    }

    ///MARK: Resetting and showing error messages

    /**
    Reset the whole error view with no image and message.
    */
    func resetErrorImage() {
        errorImageView?.image = nil
        messageLabel?.stringValue = ""
    }

    /**
     Show that the JSON is fine with proper icon.
     */
    func correctJSONMessage() {
        errorImageView?.image = NSImage.init(named: "success")
        messageLabel?.stringValue = "Valid JSON!"
    }

    /**
     Show the invalid JSON error with proper error and message.

     - parameters:
     - message: Error message that is to be shown.
     */
    func invalidJSONError(message: String) {
        errorImageView?.image = NSImage.init(named: "failure")
        messageLabel?.stringValue = message
    }

    //MARK: TextView Delegate
    func textDidChange(notification: NSNotification) {
        validateAndFormat(false)
    }

    //MARK: Internal Methods

    /**
    Open the file selector to select a location to save the generated files.

    - returns: Return a valid path or nil.
    */
    func openFile() -> String? {

        let fileDialog: NSOpenPanel = NSOpenPanel()
        fileDialog.canChooseFiles = false
        fileDialog.canChooseDirectories = true
        fileDialog.canCreateDirectories = true
        
        if fileDialog.runModal() == NSModalResponseOK {
            return fileDialog.URL?.path
        }
        
        return nil
    }
    
}
