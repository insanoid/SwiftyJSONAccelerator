//
//  ViewController.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 16/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate {
    
    @IBOutlet var textView: SJTextView?
    @IBOutlet var messageLabel: NSTextField?
    @IBOutlet var errorImageView: NSImageView?
    
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
    
    
    func handleError(error: NSError?) {
        let alert: NSAlert = NSAlert.init(error: error!)
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
        alert.runModal()
    }
    
    func resetErrorImage() {
        errorImageView?.image = nil
        messageLabel?.stringValue = ""
    }
    
    func correctJSONMessage() {
        errorImageView?.image = NSImage.init(named: "success")
        messageLabel?.stringValue = "Valid JSON!"
    }
    
    func invalidJSONError(message: String) {
         errorImageView?.image = NSImage.init(named: "failure")
        messageLabel?.stringValue = message
    }
}

