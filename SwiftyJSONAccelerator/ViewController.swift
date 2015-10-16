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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView!.delegate = self
        textView!.updateFormat()
        textView!.lnv_setUpLineNumberView()
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
            } else if error != nil {
                let alert: NSAlert = NSAlert.init(error: error!)
                if let _ = error!.userInfo["debugDescription"] as? String? {
                    alert.messageText = error!.userInfo["NSDebugDescription"]! as! String
                }
                alert.runModal()
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
    
}

