//
//  SJTextView.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 16/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Cocoa

public extension NSColor {
    @inline(__always) convenience init(RGB hex: UInt32, alpha: CGFloat = 1) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0

        self.init(deviceRed: red, green: green, blue: blue, alpha: alpha)
    }
}

public extension NSView {
    @inline(__always) var isDarkMode: Bool {
        if #available(OSX 10.14, *) {
            return effectiveAppearance.name == .darkAqua
        }

        return false
    }
}

/// A textview customization to handle formatting and handling removal of quotes.
class SJTextView: NSTextView {
    let lightTextColor = NSColor(RGB: 0x24292D)
    let lightBackgroundColor = NSColor(RGB: 0xF6F8FA)

    let darkTextColor = NSColor(RGB: 0xD1D5DA)
    let darkBackgroundColor = NSColor(RGB: 0x24292D)

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

        let color = NSColor(RGB: 0x07C160)
        insertionPointColor = color
        selectedTextAttributes = [.backgroundColor: color.withAlphaComponent(0.2)]

        if isDarkMode {
            textColor = darkTextColor
            backgroundColor = darkBackgroundColor
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
