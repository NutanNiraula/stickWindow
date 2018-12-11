//
//  main.swift
//  stickWindow
//
//  Created by Nutan Niraula on 12/10/18.
//  Copyright © 2018 Nutan Niraula. All rights reserved.
//

import Foundation
import Cocoa

var notesApp: NSRunningApplication!
var skypeForBusiness: NSRunningApplication?

struct AttachStatus {
    static var detach = false
}

class AppObserver: NSObject {
    func setUpApps() {
        for app: NSRunningApplication in NSWorkspace.shared.runningApplications {
            //TODO: change this check to bundle id
            if app.localizedName == "Notes" {
                notesApp = app
                //                print("\(app.localizedName ?? "")")
            }
            if app.localizedName == "Skype for Business" {
                skypeForBusiness = app
                print("master app \(app)")
            }
        }
    }
}

let processManager = ProcessManager()
let appObserver = AppObserver()
appObserver.setUpApps()
var backgroundQueue = OperationQueue()

print(notesApp.processIdentifier.description)

func attachWindow() {
//    DispatchQueue.global(qos: .background).async {
//    backgroundQueue.add .addOperation {
        while !AttachStatus.detach {
//            DispatchQueue.main.async {
                processManager.moveWindow(ofApp: notesApp!, withApp: skypeForBusiness!)
//            }
        }
//    }
//    }
}

let center = NSWorkspace.shared.notificationCenter
center.addObserver(forName: NSWorkspace.didLaunchApplicationNotification,
                   object: nil, // always NSWorkspace
queue: OperationQueue.main) { (notification: Notification) in
    if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
        if app.localizedName == "Skype for Business" {
            // User just launched the Terminal app
            print("skype launched")
            skypeForBusiness = app
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                attachWindow()
            })
        }
    }
}

center.addObserver(forName: NSWorkspace.didTerminateApplicationNotification,
                   object: nil, // always NSWorkspace
queue: OperationQueue.main) { (notification: Notification) in
    if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
        if app.localizedName == "Skype for Business" {
            // User just launched the Terminal app
            print("skype killed")
            skypeForBusiness = app
            AttachStatus.detach = true
//            backgroundQueue.cancelAllOperations()
//            attachWindow()
        }
    }
}

center.addObserver(forName: NSWorkspace.didTerminateApplicationNotification,
                   object: nil, // always NSWorkspace
queue: OperationQueue.main) { (notification: Notification) in
    if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
        if app.localizedName == "Notes" {
            exit(1)
        }
    }
}

//while true {
//    if NSWorkspace.shared.frontmostApplication == notesApp {
//        moveWindow(ofApp: remindersApp, withApp: notesApp)
//    } else if NSWorkspace.shared.frontmostApplication == remindersApp {
//        moveWindow(ofApp: notesApp, withApp: remindersApp)
//    }
//    print("terminated status\(skypeForBusiness.isTerminated)")
//    print("active status\(skypeForBusiness.isActive)")
//    print("hidden status\(skypeForBusiness.isHidden)")
//    sleep(1)

if skypeForBusiness != nil {
    attachWindow()
}

print("status of notes \(notesApp.isActive)")
//processManager.moveWindow(ofApp: notesApp!, withApp: skypeForBusiness!)
//}


//dispatchMain()
RunLoop.main.run()







































//if let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: AnyObject]] {
//    for window in windowList {
//        if let appPID = attachedApp?.processIdentifier, let windowPID = window[kCGWindowOwnerPID as String] as? Int {
//            //            print(windowPID)
//            print(window)
//            //            while appPID == windowPID {
//            let number = window[kCGWindowNumber as String]!
//            let bounds = CGRect(dictionaryRepresentation: window[kCGWindowBounds as String] as! CFDictionary)!
//            let name = window[kCGWindowOwnerName as String] as? String ?? ""
//            moveWindowToDesiredLocation(forPID: attachedApp.processIdentifier, masterAppPid: masterApp.processIdentifier)
//            //                print(window)
//            print("number = \(number), name = \(name), bounds = \(bounds)")
//            //            }
//        }
//    }
//} else {
//    print("Can't get window list")
//}

//func moveWindowToDesiredLocation(forPID pid: pid_t) {
//    let appRef = AXUIElementCreateApplication(pid)  //TopLevel Accessability Object of PID
//    var value: AnyObject?
//    let result = AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value)
//    print(result == AXError.success)
//    if let windowList = value as? [AXUIElement] {
//        print ("windowList #\(windowList)")
//        print(value)
//        if let window = windowList.first
//        {
//            var position : CFTypeRef
//            var size : CFTypeRef
//            var newPoint = CGPoint(x: 100, y: 100)
//            var newSize = CGSize(width: 500, height: 500)
//
//            position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPoint)!;
//            AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, position);
//            size = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!,&newSize)!;
//            AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, size);
//            print("called")
//        }
//    }
//}
