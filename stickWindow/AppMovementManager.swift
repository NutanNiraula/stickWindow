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
    
    var oldPosition = CGPoint.zero
    
    func getPosition(ofRunningApp app: NSRunningApplication) -> CGPoint? {
        if let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: AnyObject]] {
            for window in windowList {
                if let windowPID = window[kCGWindowOwnerPID as String] as? Int {
                    if app.processIdentifier == windowPID {
                        let bounds = CGRect(dictionaryRepresentation: window[kCGWindowBounds as String] as! CFDictionary)!
                        //                        print(bounds)
                        return CGPoint(x: bounds.origin.x + bounds.width, y: bounds.origin.y)
                    }
                }
            }
        }
        return nil
    }
    
    func moveWindow(ofApp attachedApp: NSRunningApplication, withApp masterApp: NSRunningApplication) {
        let appRef = AXUIElementCreateApplication(attachedApp.processIdentifier)  //TopLevel Accessability Object of PID
        var value: AnyObject?
        let result = AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value)
        //        print(result == AXError.success)
        if let windowList = value as? [AXUIElement], result == AXError.success {
            if let window = windowList.first
            {
                var position : CFTypeRef
                guard var newPoint = getPosition(ofRunningApp: masterApp) else {return}
                if newPoint != oldPosition {
                    position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPoint)!;
                    AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, position);
                }
                oldPosition = newPoint
            }
        }
    }
    
    func clearOldPosition() {
        oldPosition = CGPoint.zero
    }
}
