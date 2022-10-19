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
        textStorage?.font = NSFont(name: "Menlo", size: 12)
        textColor = NSColor.textColor
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
}
