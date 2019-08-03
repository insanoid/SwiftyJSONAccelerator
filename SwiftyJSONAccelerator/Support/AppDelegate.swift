//
//  AppDelegate.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 24/07/2019.
//  Copyright © 2019 Karthikeya Udupa. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        NSUserNotificationCenter.default.delegate = self
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }

    func userNotificationCenter(_: NSUserNotificationCenter, shouldPresent _: NSUserNotification) -> Bool {
        // Since our notification is to be shown when app is in focus, this function always returns true.
        return true
    }

    func userNotificationCenter(_: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        guard let pathString = notification.userInfo![Constants.filePathKey] as? String else {
            return
        }
        // Open the path for the notification.
        let urlPath = URL(fileURLWithPath: pathString, isDirectory: true)
        if notification.activationType == .actionButtonClicked {
            NSWorkspace.shared.activateFileViewerSelecting([urlPath])
        }
    }
}
