//
//  SJEditorViewController.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 16/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Cocoa

fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func <= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    default:
        return !(rhs < lhs)
    }
}

/// View for the processing of the content and generation of the files.
class SJEditorViewController: NSViewController, NSTextViewDelegate {

    // MARK: Outlet files.
    @IBOutlet var textView: SJTextView!
    @IBOutlet var errorImageView: NSImageView!
    @IBOutlet var baseClassTextField: NSTextField!
    @IBOutlet var prefixClassTextField: NSTextField!
    @IBOutlet var companyNameTextField: NSTextField!
    @IBOutlet var authorNameTextField: NSTextField!
    @IBOutlet var includeHeaderImportCheckbox: NSButton!
    @IBOutlet var enableNSCodingSupportCheckbox: NSButton!
    @IBOutlet var setAsFinalCheckbox: NSButton!
    @IBOutlet var librarySelector: NSPopUpButton!
    @IBOutlet var modelTypeSelectorSegment: NSSegmentedControl!

    // MARK: View methods
    override func loadView() {
        super.loadView()
        textView!.delegate = self
        textView!.updateFormat()
        textView!.lnv_setUpLineNumberView()
        resetErrorImage()
        authorNameTextField?.stringValue = NSFullUserName()
    }

    // MARK: Actions
    @IBAction func format(_ sender: AnyObject?) {
        if validateAndFormat(true) {
            generateModel()
        }

    }

    @IBAction func handleMultipleFiles(_ sender: AnyObject?) {
        let folderPath = openFile()
        // No file path was selected, go back!
        guard let path = folderPath else { return }

        do {
            let generatedModelInfo = try MultipleModelGenerator.generate(forPath: path)
            for file in generatedModelInfo.modelFiles {
                let content = FileGenerator.generateFileContentWith(file, configuration: generatedModelInfo.configuration)
                let name = file.fileName
                try FileGenerator.writeToFileWith(name, content: content, path: generatedModelInfo.configuration.filePath)
            }
            notify(fileCount: generatedModelInfo.modelFiles.count)

        } catch let error as MultipleModelGeneratorError {
            let alert: NSAlert = NSAlert()
            alert.messageText = "Unable to generate the files."
            alert.informativeText = error.errorMessage()
            alert.runModal()
        } catch let error as NSError {
            let alert: NSAlert = NSAlert()
            alert.messageText = "Unable to generate the files."
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
    }

    /**
   Validates and updates the textview.

   - parameter pretty: If the JSON is to be pretty printed.

   - returns: if the format was valid.
   */
    func validateAndFormat(_ pretty: Bool) -> Bool {

        if textView?.string.count == 0 {
            return false
        }

        textView!.updateFormat()
        let (valid, error): (Bool, NSError?) = JSONHelper.isStringValidJSON(textView?.string)
        if valid {
            if pretty {
                textView?.string = JSONHelper.prettyJSON(textView?.string)!
                textView!.lnv_textDidChange(Notification.init(name: NSText.didChangeNotification, object: nil))
                return true
            }
            correctJSONMessage()
        } else if error != nil {
            handleError(error)
            textView!.lnv_textDidChange(Notification.init(name: NSText.didChangeNotification, object: nil))
            return false
        } else {
            genericJSONError()
        }
        return false
    }

    /**
   Actual function that generates the model.
   */
    func generateModel() {

        // The base class field is blank, cannot proceed without it.
        // Possibly can have a default value in the future.
        if baseClassTextField?.stringValue.count <= 0 {
            let alert = NSAlert()
            alert.messageText = "Enter a base class name to continue."
            alert.runModal()
            return
        }

        let filePath = openFile()

        // No file path was selected, go back!
        if filePath == nil {
            return
        }

        let object: AnyObject? = JSONHelper.convertToObject(textView?.string).1

        // Checks for validity of the content, else can cause crashes.
        if object != nil {

            let nsCodingState = self.enableNSCodingSupportCheckbox.state.rawValue == 1 && (modelTypeSelectorSegment.selectedSegment == 1)
            let isFinalClass = self.setAsFinalCheckbox.state.rawValue == 1 && (modelTypeSelectorSegment.selectedSegment == 1)
            let constructType = self.modelTypeSelectorSegment.selectedSegment == 0 ? ConstructType.structType : ConstructType.classType
            let libraryType = libraryForIndex(self.librarySelector.indexOfSelectedItem)
            let configuration = ModelGenerationConfiguration.init(
                                                                  filePath: filePath!.appending("/"),
                                                                  baseClassName: baseClassTextField.stringValue,
                                                                  authorName: authorNameTextField.stringValue,
                                                                  companyName: companyNameTextField.stringValue,
                                                                  prefix: prefixClassTextField.stringValue,
                                                                  constructType: constructType,
                                                                  modelMappingLibrary: libraryType,
                                                                  supportNSCoding: nsCodingState,
                                                                  isFinalRequired: isFinalClass,
                                                                  isHeaderIncluded: includeHeaderImportCheckbox.state.rawValue == 1 ? true : false)
            let modelGenerator = ModelGenerator.init(JSON(object!), configuration)
            let filesGenerated = modelGenerator.generate()
            for file in filesGenerated {
                let content = FileGenerator.generateFileContentWith(file, configuration: configuration)
                let name = file.fileName
                let path = configuration.filePath
                do {
                    try FileGenerator.writeToFileWith(name, content: content, path: path)
                } catch let error as NSError {
                    let alert: NSAlert = NSAlert()
                    alert.messageText = "Unable to generate the files, please check the contents of the folder."
                    alert.informativeText = error.localizedDescription
                    alert.runModal()
                }
            }
            notify(fileCount: filesGenerated.count)
        } else {
            let alert: NSAlert = NSAlert()
            alert.messageText = "Unable to save the file check the content."
            alert.runModal()
        }
    }

    func libraryForIndex(_ index: Int) -> JSONMappingLibrary {
        if index == 2 {
            return JSONMappingLibrary.libObjectMapper
        } else if index == 3 {
            return JSONMappingLibrary.libMarshal
        }
        return JSONMappingLibrary.libSwiftyJSON
    }

    @IBAction func recalcEnabledBoxes(_ sender: AnyObject) {
        self.enableNSCodingSupportCheckbox.isEnabled = (modelTypeSelectorSegment.selectedSegment == 1)
        self.setAsFinalCheckbox.isEnabled = (modelTypeSelectorSegment.selectedSegment == 1)
    }

    func notify(fileCount: Int) {
        let notification = NSUserNotification()
        notification.title = "SwiftyJSONAccelerator"
        if fileCount > 0 {
            notification.subtitle = "Completed - \(fileCount) Files Generated"
        } else {
            notification.subtitle = "No files were generated."
        }
        NSUserNotificationCenter.default.deliver(notification)
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
    func characterRowAndLineAt(_ string: String, position: Int)
        -> (character: String, line: Int, column: Int) {
            var lineNumber = 0
            var characterPosition = 0
            for line in string.components(separatedBy: "\n") {
                lineNumber += 1
                var columnNumber = 0
                // TODO: Check this.
                for column in line {
                    characterPosition += 1
                    columnNumber += 1
                    if characterPosition == position {
                        return (String(column), lineNumber, columnNumber)
                    }
                }
                characterPosition += 1
                if characterPosition == position {
                    return ("\n", lineNumber, columnNumber + 1)
                }
            }
            return ("", 0, 0)
    }

    /**
   Handle Error message that is provided by the JSON helper and extract the message and showing them accordingly.

   - parameters:
   - error: NSError that was provided.
   */
    func handleError(_ error: NSError?) {
        if let message = error!.userInfo["debugDescription"] as? String {
            let numbers = message.components(separatedBy: CharacterSet.decimalDigits.inverted)

            var validNumbers: [Int] = []
            for number in numbers where (Int(number) != nil) {
                validNumbers.append(Int(number)!)
            }

            if validNumbers.count == 1 {
                let index = validNumbers[0]
                let errorPosition: (character: String, line: Int, column: Int) = characterRowAndLineAt((textView?.string)!, position: index)
                let customErrorMessage = "Error at line number: \(errorPosition.line) column: \(errorPosition.column) at Character: \(errorPosition.character)."
                invalidJSONError(customErrorMessage)
            } else {
                invalidJSONError(message)
            }
        } else {
            genericJSONError()
        }
    }

    /**
     Shows a generic error about JSON in case the system is not able to figure out what is wrong.
     */
    func genericJSONError() {
        invalidJSONError("The JSON seems to be invalid!")
    }

    /// MARK: Resetting and showing error messages

    /**
   Reset the whole error view with no image and message.
   */
    func resetErrorImage() {
        errorImageView?.image = nil
    }

    /**
   Show that the JSON is fine with proper icon.
   */
    func correctJSONMessage() {
        errorImageView?.image = NSImage.init(named: "success")
    }

    /**
   Show the invalid JSON error with proper error and message.

   - parameters:
   - message: Error message that is to be shown.
   */
    func invalidJSONError(_ message: String) {
        errorImageView?.image = NSImage.init(named: "failure")
    }

    // MARK: TextView Delegate
    func textDidChange(_ notification: Notification) {
        let isValid = validateAndFormat(false)
        if isValid {
            resetErrorImage()
        }
    }

    @IBAction func librarySwitched(sender: Any) {
        if let menu = sender as? NSPopUpButton {
            self.librarySelector.title = menu.selectedItem!.title
        }
    }

    // MARK: Internal Methods

    /**
   Open the file selector to select a location to save the generated files.

   - returns: Return a valid path or nil.
   */
    func openFile() -> String? {
        let fileDialog = NSOpenPanel()
        fileDialog.canChooseFiles = false
        fileDialog.canChooseDirectories = true
        fileDialog.canCreateDirectories = true
        if fileDialog.runModal() == NSApplication.ModalResponse.OK {
            return fileDialog.url?.path
        }
        return nil
    }

}
