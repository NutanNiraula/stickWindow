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

class ProcessManager {
    func getPosition(ofRunningApp app: NSRunningApplication) -> CGPoint {
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
        return CGPoint.zero
    }
    
    func moveWindow(ofApp attachedApp: NSRunningApplication, withApp masterApp: NSRunningApplication) {
        let appRef = AXUIElementCreateApplication(attachedApp.processIdentifier)  //TopLevel Accessability Object of PID
        var value: AnyObject?
        let result = AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value)
//        print(result == AXError.success)
        if let windowList = value as? [AXUIElement] {
            if let window = windowList.first
            {
                var position : CFTypeRef
                var newPoint = getPosition(ofRunningApp: masterApp)
                position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPoint)!;
                AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, position);
            }
        }
    }
}
