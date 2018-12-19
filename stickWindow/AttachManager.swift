//
//  AttachManager.swift
//  stickWindow
//
//  Created by Nutan Niraula on 12/14/18.
//  Copyright © 2018 Nutan Niraula. All rights reserved.
//

import Foundation
import Cocoa
import ApplicationServices

class AttachManager {
    
    var vonageApp: NSRunningApplication! //{
//        didSet {
//            observeMouseActionOnProcessId(processId: vonageApp.processIdentifier)
//        }
//    }
    var count = 0
    var skypeForBusinessApp: NSRunningApplication? {
        didSet {
            if let pid = skypeForBusinessApp?.processIdentifier {
                observeMouseActionOnProcessId(processId: pid)
                count = count + 1
                p.debugPrint(propertyValue: "\(count)")
            }
        }
    }
    var activeApp: NSRunningApplication?
    var movementManager: AppMovementManager!
    var processObserver: NotificationCenter!
    //    var backgroundQueue = OperationQueue() //if used cancelAllOperation from background queue on completion
    
    private let vonage = AppLocalName.vonage
    private let skypeForBusiness = AppLocalName.skypeForBusiness
    
    typealias p = PrintUtility
    
    init(withMovementManager mManager: AppMovementManager, processObserver pObserver: NotificationCenter) {
        movementManager = mManager
        processObserver = pObserver
    }
    
    func assignActiveApps() {
        for app: NSRunningApplication in NSWorkspace.shared.runningApplications {
            //TODO: change this check to bundle id
            if app.localizedName == vonage {
                vonageApp = app
            }
            if app.localizedName == skypeForBusiness {
                skypeForBusinessApp = app
                activeApp = skypeForBusinessApp
            }
        }
    }
    
     func attachVonageWindowToSkypeIfSkypeIsLaunched() {
        if skypeForBusinessApp != nil {
            guard let skype = skypeForBusinessApp else {return}
            if activeApp == skype && vonageApp != nil {
                movementManager.moveWindow(ofAttachedApp: vonageApp!, withMasterApp: skype)
            } else if activeApp == vonageApp {
                movementManager.moveWindow(ofMasterApp: skype, withAttachedApp: vonageApp)
            }
        }
    }
    
    func attachVonageToSkypeOnLaunchingSkype() {
        processObserver.addObserver(forName: NSWorkspace.didLaunchApplicationNotification,
                                    object: nil, // always NSWorkspace
        queue: OperationQueue.main) { [weak self] (notification: Notification) in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.localizedName == self?.skypeForBusiness {
                    p.debugPrint(propertyValue: "Skype launched")
                    self?.skypeForBusinessApp = app
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self?.attachVonageWindowToSkypeIfSkypeIsLaunched()
                    })
                }
            }
        }
    }
    
    func attachVonageToSkypeOnLaunchingVonage() {
        processObserver.addObserver(forName: NSWorkspace.didLaunchApplicationNotification,
                                    object: nil, // always NSWorkspace
        queue: OperationQueue.main) { [weak self] (notification: Notification) in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.localizedName == self?.vonage {
                    p.debugPrint(propertyValue: "Vonage launched")
                    self?.vonageApp = app
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self?.attachVonageWindowToSkypeIfSkypeIsLaunched()
                    })
                }
            }
        }
    }
    
    func attachVonageToSkypeOnUnhidingSkype() {
        processObserver.addObserver(forName: NSWorkspace.didUnhideApplicationNotification,
                                    object: nil, // always NSWorkspace
        queue: OperationQueue.main) { [weak self] (notification: Notification) in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.localizedName == self?.skypeForBusiness {
                    p.debugPrint(propertyValue: "Skype Unhidden")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self?.attachVonageWindowToSkypeIfSkypeIsLaunched()
                    })
                }
            }
        }
    }
    
    func attachSkypeToVonageOnUnhidingVonage() {
        processObserver.addObserver(forName: NSWorkspace.didUnhideApplicationNotification,
                                    object: nil, // always NSWorkspace
        queue: OperationQueue.main) { [weak self] (notification: Notification) in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.localizedName == self?.vonage {
                    p.debugPrint(propertyValue: "Vonage Unhidden")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self?.attachVonageWindowToSkypeIfSkypeIsLaunched()
                    })
                }
            }
        }
    }
    
    func detachVonageFromSkypeOnSkypeTermination() {
        processObserver.addObserver(forName: NSWorkspace.didTerminateApplicationNotification,
                                    object: nil, // always NSWorkspace
        queue: OperationQueue.main) { [weak self] (notification: Notification) in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.localizedName == self?.skypeForBusiness {
                    p.debugPrint(propertyValue: "Skype app killed")
                    self?.skypeForBusinessApp = nil
                    self?.movementManager.clearOldPositionOfMasterApp()
                }
            }
        }
    }
    
    func observeActiveApp() {
        processObserver.addObserver(forName: NSWorkspace.didActivateApplicationNotification,
                                    object: nil, // always NSWorkspace
        queue: OperationQueue.main) { [weak self] (notification: Notification) in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.localizedName == self?.skypeForBusiness || app.localizedName == self?.vonage {
                    p.debugPrint(propertyValue: "\(app.localizedName ?? "") is actively selected")
                    self?.activeApp = app
                }
            }
        }
    }
    
    func exitOnVonageTermination() {
        processObserver.addObserver(forName: NSWorkspace.didTerminateApplicationNotification,
                                    object: nil, // always NSWorkspace
        queue: OperationQueue.main) { (notification: Notification) in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.localizedName == self.vonage {
                    p.debugPrint(propertyValue: "Vonage app killed")
                    CLICommandManager.exitMain()
                }
            }
        }
    }
    
    func observeMouseActionOnProcessId(processId pid: pid_t) {
        
        let callback: CGEventTapCallBack =  { (tapProxy, eventType, event, refcon) -> Unmanaged<CGEvent>? in
//            p.debugPrint(propertyName: "Mouse Location:", propertyValue: "\(event.location))")
            // This code below will attempt to convert unsafe pointer object to specific type but since from within this callback self cannot be captured bridge function needs to be implemented locally here
            let attachManagerSelf = Unmanaged<AttachManager>.fromOpaque(refcon!).takeUnretainedValue()
            attachManagerSelf.attachVonageWindowToSkypeIfSkypeIsLaunched()
            return nil
        }
        
        let eventMask = (1 << CGEventType.leftMouseDragged.rawValue) //| (1 << CGEventType.leftMouseDown.rawValue) // do not mask mousedown as it will hijack mouse event from skype for business
        
        
        //userInfo is an unsafePointer that will be passed to callback parameter later on so, passing self's pointer here and unwrapping it inside the C callback I can call swift function from within c pointer callback
        let machPort = CGEvent.tapCreateForPid(pid: pid, place: .tailAppendEventTap, options: .defaultTap, eventsOfInterest: CGEventMask(eventMask), callback: callback, userInfo: bridge(obj: self))!
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, machPort, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: machPort, enable: true)
    }
}

extension AttachManager {
    // converting unsafe pointer from c to self and vice versa
    // copied from https://stackoverflow.com/questions/33294620/how-to-cast-self-to-unsafemutablepointervoid-type-in-swift
    //modified the code to pass unsafemutablerawPointer rather than unsafeRawPointer
    func bridge<T : AnyObject>(obj : T) -> UnsafeMutableRawPointer {
       return Unmanaged.passUnretained(obj).toOpaque()
    }
    
    func bridge<T : AnyObject>(ptr : UnsafeMutableRawPointer) -> T {
        return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
    }
    //retained versions are not used currently
    func bridgeRetained<T : AnyObject>(obj : T) -> UnsafeMutableRawPointer {
        return Unmanaged.passRetained(obj).toOpaque()
    }
    
    func bridgeTransfer<T : AnyObject>(ptr : UnsafeMutableRawPointer) -> T {
        return Unmanaged<T>.fromOpaque(ptr).takeRetainedValue()
    }
}
