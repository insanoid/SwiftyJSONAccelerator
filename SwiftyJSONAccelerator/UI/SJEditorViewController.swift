//
//  ViewController.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 24/07/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Cocoa
import SwiftyJSON

class SJEditorViewController: NSViewController, NSTextViewDelegate {
    // MARK: Outlet files.

    @IBOutlet var textView: SJTextView!
    @IBOutlet var errorImageView: NSImageView!
    @IBOutlet var baseClassTextField: NSTextField!
    @IBOutlet var prefixClassTextField: NSTextField!
    @IBOutlet var companyNameTextField: NSTextField!
    @IBOutlet var authorNameTextField: NSTextField!
    @IBOutlet var variablesOptionalCheckbox: NSButton!
    @IBOutlet var separateCodingKeysCheckbox: NSButton!
    @IBOutlet var librarySelector: NSPopUpButton!
    @IBOutlet var modelTypeSelectorSegment: NSSegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.updateFormat()
        resetView()
        textView!.lnv_setUpLineNumberView()

        // Do any additional setup after loading the view.
    }

    func resetView() {
        textView.string = ""
        baseClassTextField.stringValue = "BaseClass"
        resetErrorImage()
        authorNameTextField?.stringValue = NSFullUserName()
        companyNameTextField.stringValue = ""
        prefixClassTextField.stringValue = ""
        librarySelector.selectItem(at: 0)
        modelTypeSelectorSegment.selectSegment(withTag: 0)
        variablesOptionalCheckbox.state = .on
        separateCodingKeysCheckbox.state = .on
    }

    /// Validate and updates the textview
    ///
    /// - Parameter pretty: If the JSON is to be pretty printed.
    /// - Returns: If the format was valid.
    func validateAndFormat(_ pretty: Bool) -> Bool {
        if textView?.string.isEmpty == true {
            return false
        }
        textView!.updateFormat()
        let parserResponse = JSONHelper.isStringValidJSON(textView?.string)
        if parserResponse.isValid {
            correctJSONMessage()
            if pretty {
                textView?.string = JSONHelper.prettyJSON(textView?.string)!
                textView!.lnv_textDidChange(Notification(name: NSText.didChangeNotification, object: nil))
                return true
            }
        } else if parserResponse.error != nil {
            handleError(parserResponse.error)
            textView!.lnv_textDidChange(Notification(name: NSText.didChangeNotification, object: nil))
            return false
        } else {
            genericJSONError()
        }
        return false
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

/// TextView and UI actions
extension SJEditorViewController {
    /// TextView delegate when change occurs.
    func textDidChange(_: Notification) {
        let isValid = validateAndFormat(false)
        if isValid {
            resetErrorImage()
        }
    }

    /// Handle loading multiple files at once
    @IBAction func handleMultipleFiles(_: AnyObject?) {
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
            notify(fileCount: generatedModelInfo.modelFiles.count, path: generatedModelInfo.configuration.filePath)

        } catch let error as MultipleModelGeneratorError {
            let alert = NSAlert()
            alert.messageText = "Unable to generate the files."
            alert.informativeText = error.errorMessage()
            alert.runModal()
        } catch let error as NSError {
            let alert = NSAlert()
            alert.messageText = "Unable to generate the files."
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
    }

    /// Default function when "Open > New" is clicked.
    @IBAction func newDocument(_: Any?) {
        resetView()
    }

    /// When switching between versions of code being generated
    @IBAction func librarySwitched(sender: Any) {
        if let menu = sender as? NSPopUpButton {
            librarySelector.title = menu.selectedItem!.title
        }
    }

    /// Mapping method to be used based on the selector control
    func mappingMethodForIndex(_ index: Int) -> JSONMappingMethod {
        if index == 2 {
            return JSONMappingMethod.swiftCodeExtended
        }
        return JSONMappingMethod.swiftNormal
    }

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

    func notify(fileCount: Int, path: String) {
        let notification = NSUserNotification()
        notification.identifier = "SwiftyJSONAccelerator-" + UUID().uuidString
        notification.title = "SwiftyJSONAccelerator"
        if fileCount > 0 {
            notification.subtitle = "Completed - \(fileCount) Files Generated"
        } else {
            notification.subtitle = "No files were generated."
        }
        notification.userInfo = [Constants.filePathKey: path]
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.hasActionButton = true
        notification.actionButtonTitle = "View"
        NSUserNotificationCenter.default.deliver(notification)
    }

    /// Function to format the code.
    @IBAction func format(_: AnyObject?) {
        if validateAndFormat(true) {
            generateModel()
        }
    }

    /// Main function to generate the model based on the options selected by the customer.
    func generateModel() {
        // The base class field is blank, cannot proceed without it.
        // Possibly can have a default value in the future.
        guard !baseClassTextField!.stringValue.isEmpty else {
            let alert = NSAlert()
            alert.messageText = "Enter a base class name to continue."
            alert.runModal()
            return
        }

        // Filepath to get the location to save the files.
        let filePath = openFile()

        // No file path was selected, cannot proceed ahead.
        if filePath == nil {
            return
        }

        let parserResponse = JSONHelper.convertToObject(textView?.string)

        // Checks for validity of the content, else can cause crashes.
        if parserResponse.parsedObject != nil {
            let destinationPath = filePath!.appending("/")
            let variablesOptional = variablesOptionalCheckbox.state.rawValue == 1
            let separateCodingKeys = separateCodingKeysCheckbox.state.rawValue == 1
            let constructType = modelTypeSelectorSegment.selectedSegment == 0 ? ConstructType.structType : ConstructType.classType
            let libraryType = mappingMethodForIndex(librarySelector.indexOfSelectedItem)
            let configuration = ModelGenerationConfiguration(
                filePath: destinationPath,
                baseClassName: baseClassTextField.stringValue,
                authorName: authorNameTextField.stringValue,
                companyName: companyNameTextField.stringValue,
                prefix: prefixClassTextField.stringValue,
                constructType: constructType,
                modelMappingLibrary: libraryType,
                separateCodingKeys: separateCodingKeys,
                variablesOptional: variablesOptional
            )
            let modelGenerator = ModelGenerator(JSON(parserResponse.parsedObject!), configuration)
            let filesGenerated = modelGenerator.generate()
            for file in filesGenerated {
                let content = FileGenerator.generateFileContentWith(file, configuration: configuration)
                let name = file.fileName
                let path = configuration.filePath
                do {
                    try FileGenerator.writeToFileWith(name, content: content, path: path)
                } catch let error as NSError {
                    let alert = NSAlert()
                    alert.messageText = "Unable to generate the files, please check the contents of the folder."
                    alert.informativeText = error.localizedDescription
                    alert.runModal()
                }
            }
            notify(fileCount: filesGenerated.count, path: destinationPath)
        } else {
            let alert = NSAlert()
            alert.messageText = "Unable to save the file check the content."
            alert.runModal()
        }
    }
}

// MARK: - Resetting and showing error messages

extension SJEditorViewController {
    ///  Reset the whole error view with no image and message.
    func genericJSONError() {
        invalidJSONError("The JSON seems to be invalid!")
    }

    /// Reset the whole error view with no image and message.
    func resetErrorImage() {
        errorImageView?.image = nil
    }

    /// Show that the JSON is fine with proper icon.
    func correctJSONMessage() {
        errorImageView?.image = NSImage(named: "success")
    }

    /// Show the invalid JSON error with proper error and message.
    ///
    /// - Parameter message: Error message that is to be shown.
    func invalidJSONError(_: String) {
        errorImageView?.image = NSImage(named: "failure")
    }

    /// Handle Error message that is provided by the JSON helper and extract the message and showing them accordingly.
    ///
    /// - Parameter error: NSError that was provided.
    func handleError(_ error: NSError?) {
        if let message = error!.userInfo["debugDescription"] as? String {
            let numbers = message.components(separatedBy: CharacterSet.decimalDigits.inverted)

            var validNumbers: [Int] = []
            for number in numbers where Int(number) != nil {
                validNumbers.append(Int(number)!)
            }

            if validNumbers.count == 1 {
                let index = validNumbers[0]
                let errorPosition: CharacterPosition = (textView?.string)!.characterRowAndLineAt(position: index)
                let customErrorMessage = "Error at line number: \(errorPosition.line) column: \(errorPosition.column) at Character: \(errorPosition.character)."
                invalidJSONError(customErrorMessage)
            } else {
                invalidJSONError(message)
            }
        } else {
            genericJSONError()
        }
    }
}
