//
//  ProcessManager.swift
//  stickWindow
//
//  Created by Nutan Niraula on 12/11/18.
//  Copyright © 2018 Nutan Niraula. All rights reserved.
//

import Foundation
import AppKit
import Cocoa

class AppMovementManager {
    
    var oldPositionOfMasterApp = CGPoint.zero
    var oldPositionOfAttachedApp = CGPoint.zero
    
    func getBounds(ofRunningApp app: NSRunningApplication) -> CGRect? {
        if let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: AnyObject]] {
            for window in windowList {
                if let windowPID = window[kCGWindowOwnerPID as String] as? Int {
                    if app.processIdentifier == windowPID {
                        let bounds = CGRect(dictionaryRepresentation: window[kCGWindowBounds as String] as! CFDictionary)!
                        return bounds
                    }
                }
            }
        }
        return nil
    }
    
    func moveWindow(ofAttachedApp attachedApp: NSRunningApplication, withMasterApp masterApp: NSRunningApplication) {
        let appRef = AXUIElementCreateApplication(attachedApp.processIdentifier)  //TopLevel Accessability Object of PID
        var value: AnyObject?
        let result = AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value)
        if let windowList = value as? [AXUIElement], result == AXError.success {
            if let window = windowList.first
            {
                var position : CFTypeRef
                    guard var newPositionOfAttachedApp = getNewPositionForAttachedApp(fromMasterAppBounds: getBounds(ofRunningApp: masterApp)) else {return}
                    if newPositionOfAttachedApp != oldPositionOfAttachedApp {
                        position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPositionOfAttachedApp)!
                        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, position)
                        oldPositionOfAttachedApp = newPositionOfAttachedApp
                    }
            }
        }
    }
    
    func moveWindow(ofMasterApp masterApp: NSRunningApplication, withAttachedApp attachedApp: NSRunningApplication) {
        let appRef = AXUIElementCreateApplication(masterApp.processIdentifier)  //TopLevel Accessability Object of PID
        var value: AnyObject?
        let result = AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value)
        if let windowList = value as? [AXUIElement], result == AXError.success {
            if let window = windowList.first
            {
                var position : CFTypeRef
                guard var newPositionOfMasterApp = getNewPositionForMasterApp(fromAttachedAppBounds: getBounds(ofRunningApp: attachedApp),                                                                                  andMasterAppBounds: getBounds(ofRunningApp: masterApp)) else {return}
                if newPositionOfMasterApp != oldPositionOfMasterApp {
                    position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPositionOfMasterApp)!
                    AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, position)
                    oldPositionOfMasterApp = newPositionOfMasterApp
                }
            }
        }
    }
    
    func getNewPositionForMasterApp(fromAttachedAppBounds aBounds: CGRect?, andMasterAppBounds mBound: CGRect?) -> CGPoint? {
        if let boundOfAttachedApp = aBounds, let boundOfMasterApp = mBound {
            return (CGPoint(x: boundOfAttachedApp.origin.x - boundOfMasterApp.width, y: boundOfAttachedApp.origin.y))
        } else {
            return nil
        }
    }
    
    func getNewPositionForAttachedApp(fromMasterAppBounds bounds: CGRect?) -> CGPoint? {
        if let boundOfMasterApp = bounds {
            return (CGPoint(x: boundOfMasterApp.origin.x + boundOfMasterApp.width, y: boundOfMasterApp.origin.y))
        } else {
            return nil
        }
    }
    
    func clearOldPositionOfMasterApp() {
        oldPositionOfMasterApp = CGPoint.zero
    }

}
