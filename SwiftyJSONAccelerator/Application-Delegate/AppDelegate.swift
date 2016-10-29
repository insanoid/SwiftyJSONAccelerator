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

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    NSUserNotificationCenter.default.delegate = self
  }

  func userNotificationCenter(_ center: NSUserNotificationCenter,
    shouldPresent notification: NSUserNotification) -> Bool {
      return true
  }
}
