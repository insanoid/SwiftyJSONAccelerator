//
//  SJTextView.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 16/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Cocoa

class SJTextView: NSTextView {
    
    override var readablePasteboardTypes: [String] {
        get {
            return [NSPasteboardTypeString]
        }
    }
    
    internal func updateFormat() {
        textStorage?.font = NSFont(name: "Menlo", size: 12)
    }
    
    override func paste(sender: AnyObject?) {
        super.paste(sender)
        updateFormat()
    }
}
