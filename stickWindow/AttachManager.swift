//
//  AttachManager.swift
//  stickWindow
//
//  Created by Nutan Niraula on 12/14/18.
//  Copyright © 2018 Nutan Niraula. All rights reserved.
//

import Foundation
import Cocoa

struct AttachStatus {
    static var detach = false
}

class AttachManager {
    var vonageApp: NSRunningApplication!
    var skypeForBusinessApp: NSRunningApplication?
    var movementManager: AppMovementManager!
    var processObserver: NotificationCenter!
    var backgroundQueue = OperationQueue()
    
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
            }
        }
    }
    
    func attachVonageWindowToSkypeIfSkypeIsLaunched() {
        //    DispatchQueue.global(qos: .background).async {
        //    backgroundQueue.add .addOperation {
        if skypeForBusinessApp != nil {
//            while !AttachStatus.detach {
                //            DispatchQueue.main.async {
                movementManager.moveWindow(ofApp: vonageApp!, withApp: skypeForBusinessApp!)
                //            }
//            }
        }
        //    }
        //    }
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
    
    func detachVonageFromSkypeOnSkypeTermination() {
        processObserver.addObserver(forName: NSWorkspace.didTerminateApplicationNotification,
                                    object: nil, // always NSWorkspace
        queue: OperationQueue.main) { [weak self] (notification: Notification) in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.localizedName == self?.skypeForBusiness {
                    p.debugPrint(propertyValue: "Skype app killed")
                    self?.skypeForBusinessApp = nil
                    self?.movementManager.clearOldPosition()
                    AttachStatus.detach = true
                    //            backgroundQueue.cancelAllOperations()
                    //            attachWindow()
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
    
}
