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
    @IBOutlet var textView: SJTextView?
    @IBOutlet var messageLabel: NSTextField?
    @IBOutlet var errorImageView: NSImageView?
    
    // MARK: View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView!.delegate = self
        textView!.updateFormat()
        textView!.lnv_setUpLineNumberView()
        resetErrorImage()
        
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    // MARK: Actions
    @IBAction func format(sender: AnyObject?) {
        
        if textView?.string?.characters.count == 0 {
            return
        }
        
        if let (valid, error): (Bool, NSError?) = JSONHelper.isStringValidJSON(textView?.string) {
            if(valid){
                textView?.string = JSONHelper.prettyJSON(textView?.string)!
                correctJSONMessage()
            } else if error != nil {
                handleError(error)
            }
        }
        
        textView!.updateFormat()
        textView!.lnv_textDidChange(NSNotification.init(name: NSTextDidChangeNotification, object: nil))
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
            lineNumber++
            var columnNumber = 0
            for column in line.characters {
                characterPosition++
                columnNumber++
                if characterPosition == position {
                    return (String(column), lineNumber, columnNumber )
                }
            }
            characterPosition++
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
        format(textView)
    }
    
}

