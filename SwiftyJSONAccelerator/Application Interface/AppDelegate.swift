//
//  AppDelegate.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthik on 16/10/2015.
//  Copyright © 2015 Karthikeya Udupa K M. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }

    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}
