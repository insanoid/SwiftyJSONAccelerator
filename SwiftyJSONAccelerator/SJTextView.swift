//
//  SJTextView.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 16/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Cocoa

/// A textview customization to handle formatting and handling removal of quotes.
class SJTextView: NSTextView {
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        self.automaticQuoteSubstitutionEnabled = false
        self.automaticDashSubstitutionEnabled = false
        self.automaticTextReplacementEnabled = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.automaticQuoteSubstitutionEnabled = false
        self.automaticDashSubstitutionEnabled = false
        self.automaticTextReplacementEnabled = false
    }
    
    override var readablePasteboardTypes: [String] {
        get {
            return [NSPasteboardTypeString]
        }
    }
    
    internal func updateFormat() {
        textStorage?.font = NSFont(name: "Menlo", size: 12)
        self.textColor = NSColor.whiteColor()
    }
    
    override func paste(sender: AnyObject?) {
        super.paste(sender)
        updateFormat()
    }
}
