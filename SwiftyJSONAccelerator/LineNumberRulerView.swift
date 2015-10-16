//
//  LineNumberRulerView.swift
//  LineNumber
//
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import AppKit
import Foundation
import ObjectiveC

var LineNumberViewAssocObjKey: UInt8 = 0

extension NSTextView {
    var lineNumberView:LineNumberRulerView {
        get {
            return objc_getAssociatedObject(self, &LineNumberViewAssocObjKey) as! LineNumberRulerView
        }
        set {
            objc_setAssociatedObject(self, &LineNumberViewAssocObjKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func lnv_setUpLineNumberView() {
        if font == nil {
            font = NSFont.systemFontOfSize(12)
        }
        
        if let scrollView = enclosingScrollView {
            lineNumberView = LineNumberRulerView(textView: self)
            
            scrollView.verticalRulerView = lineNumberView
            scrollView.hasVerticalRuler = true
            scrollView.rulersVisible = true
        }
        
        postsFrameChangedNotifications = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "lnv_framDidChange:", name: NSViewFrameDidChangeNotification, object: self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "lnv_textDidChange:", name: NSTextDidChangeNotification, object: self)
    }
    
    func lnv_framDidChange(notification: NSNotification) {
        
        lineNumberView.needsDisplay = true
    }
    
    func lnv_textDidChange(notification: NSNotification) {
        
        lineNumberView.needsDisplay = true
    }
    
}

class LineNumberRulerView: NSRulerView {
    
    var font: NSFont! {
        didSet {
            self.needsDisplay = true
        }
    }
    
    init(textView: NSTextView) {
        super.init(scrollView: textView.enclosingScrollView!, orientation: NSRulerOrientation.VerticalRuler)
        self.font = textView.font ?? NSFont.systemFontOfSize(NSFont.smallSystemFontSize())
        self.clientView = textView
        
        self.ruleThickness = 40
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawHashMarksAndLabelsInRect(rect: NSRect) {
        
        if let textView = self.clientView as? NSTextView {
            if let layoutManager = textView.layoutManager {
                
                let relativePoint = self.convertPoint(NSZeroPoint, fromView: textView)
                let lineNumberAttributes = [NSFontAttributeName: textView.font!, NSForegroundColorAttributeName: NSColor.grayColor()]
                let drawLineNumber = { (lineNumberString:String, y:CGFloat) -> Void in
                    let attString = NSAttributedString(string: lineNumberString, attributes: lineNumberAttributes)
                    let x = 35 - attString.size().width
                    attString.drawAtPoint(NSPoint(x: x, y: relativePoint.y + y))
                }
                
                let visibleGlyphRange = layoutManager.glyphRangeForBoundingRect(textView.visibleRect, inTextContainer: textView.textContainer!)
                let firstVisibleGlyphCharacterIndex = layoutManager.characterIndexForGlyphAtIndex(visibleGlyphRange.location)
                
                let newLineRegex = try! NSRegularExpression(pattern: "\n", options: [])
                // The line number for the first visible line
                var lineNumber = newLineRegex.numberOfMatchesInString(textView.string!, options: [], range: NSMakeRange(0, firstVisibleGlyphCharacterIndex)) + 1
                
                var glyphIndexForStringLine = visibleGlyphRange.location
                
                // Go through each line in the string.
                while glyphIndexForStringLine < NSMaxRange(visibleGlyphRange) {
                    
                    // Range of current line in the string.
                    let characterRangeForStringLine = (textView.string! as NSString).lineRangeForRange(
                        NSMakeRange( layoutManager.characterIndexForGlyphAtIndex(glyphIndexForStringLine), 0 )
                    )
                    let glyphRangeForStringLine = layoutManager.glyphRangeForCharacterRange(characterRangeForStringLine, actualCharacterRange: nil)
                    
                    var glyphIndexForGlyphLine = glyphIndexForStringLine
                    var glyphLineCount = 0
                    
                    while ( glyphIndexForGlyphLine < NSMaxRange(glyphRangeForStringLine) ) {
                        
                        // See if the current line in the string spread across
                        // several lines of glyphs
                        var effectiveRange = NSMakeRange(0, 0)
                        
                        // Range of current "line of glyphs". If a line is wrapped,
                        // then it will have more than one "line of glyphs"
                        let lineRect = layoutManager.lineFragmentRectForGlyphAtIndex(glyphIndexForGlyphLine, effectiveRange: &effectiveRange, withoutAdditionalLayout: true)
                        
                        if glyphLineCount > 0 {
                            drawLineNumber("-", lineRect.minY)
                        } else {
                            drawLineNumber("\(lineNumber)", lineRect.minY)
                        }
                        
                        // Move to next glyph line
                        glyphLineCount++
                        glyphIndexForGlyphLine = NSMaxRange(effectiveRange)
                    }
                    
                    glyphIndexForStringLine = NSMaxRange(glyphRangeForStringLine)
                    lineNumber++
                }
                
                // Draw line number for the extra line at the end of the text
                if layoutManager.extraLineFragmentTextContainer != nil {
                    drawLineNumber("\(lineNumber)", layoutManager.extraLineFragmentRect.minY)
                }
            }
        }
        
    }
}
