//
//  ViewController.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 16/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate {
    
    @IBOutlet var textView: NSTextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        JSONHelper.isStringValidJSON("")
        JSONHelper.prettyJSON(["value":20,"zen":"budhism"])
        textView!.lnv_setUpLineNumberView()
        textView!.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func format(sender: AnyObject?) {
        if let (valid, error): (Bool, NSError?) = JSONHelper.isStringValidJSON(textView?.string) {
            if(valid){
                textView?.string = JSONHelper.prettyJSON(textView?.string)!
            } else if error != nil {
                error.debugDescription
                let alert: NSAlert = NSAlert.init(error: error!)
                alert.runModal()
            }
        }
    }
    
    func textView(textView: NSTextView, doCommandBySelector commandSelector: Selector) -> Bool {
        
        if commandSelector == Selector("paste:") {
           format(nil)
        }
        
        return true
    }
}

