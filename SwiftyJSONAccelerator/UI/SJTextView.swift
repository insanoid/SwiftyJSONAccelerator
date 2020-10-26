//
//  SJTextView.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 16/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Cocoa

extension NSColor {
 
    @inline(__always) public convenience init(RGB hex: UInt32, alpha: CGFloat = 1) {
        let red = CGFloat((hex & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xff00) >> 8) / 255.0
        let blue = CGFloat(hex & 0xff) / 255.0
        
        self.init(deviceRed: red, green: green, blue: blue, alpha: alpha)
    }
}

extension NSView {
    
    @available(OSX 10.14, *)
    @inline(__always) public func isDarkMode() -> Bool {
        effectiveAppearance.name == .darkAqua
    }
}

/// A textview customization to handle formatting and handling removal of quotes.
class SJTextView: NSTextView {
    
    let lightTextColor = NSColor(RGB: 0x24292d)
    let lightBackgroundColor = NSColor(RGB: 0xf6f8fa)
    
    let darkTextColor = NSColor(RGB: 0xd1d5da)
    let darkBackgroundColor = NSColor(RGB: 0x24292d)
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        disableAutoReplacement()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        disableAutoReplacement()
    }

    override var readablePasteboardTypes: [NSPasteboard.PasteboardType] {
        return [NSPasteboard.PasteboardType.string]
    }

    internal func updateFormat() {
        textStorage?.font = NSFont(name: "Monaco", size: 12)
        
        let color = NSColor(RGB: 0x07c160)
        insertionPointColor = color
        selectedTextAttributes = [.backgroundColor: color.withAlphaComponent(0.2)]
        
        if #available(OSX 10.14, *) {
            if isDarkMode() {
                textColor = darkTextColor
                backgroundColor = darkBackgroundColor
            } else {
                textColor = lightTextColor
                backgroundColor = lightBackgroundColor
            }
        } else {
            textColor = lightTextColor
            backgroundColor = lightBackgroundColor
        }
    }

    override func paste(_ sender: Any?) {
        super.paste(sender)
        updateFormat()
    }

    override func lnv_textDidChange(_: Notification) {
        updateFormat()
    }

    private func disableAutoReplacement() {
        isAutomaticQuoteSubstitutionEnabled = false
        isAutomaticDashSubstitutionEnabled = false
        isAutomaticTextReplacementEnabled = false
    }
    
    override func layout() {
        super.layout()
        
        updateFormat()
    }
}
