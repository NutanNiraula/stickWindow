//
//  AttachManager.swift
//  stickWindow
//
//  Created by Nutan Niraula on 12/14/18.
//  Copyright © 2018 Nutan Niraula. All rights reserved.
//

import Foundation
import Cocoa

class AttachManager {
    
    var vonageApp: NSRunningApplication!
    var skypeForBusinessApp: NSRunningApplication?
    var activeApp: NSRunningApplication?
    var movementManager: AppMovementManager!
    var processObserver: NotificationCenter!
    var backgroundQueue = OperationQueue()
    
    private let vonage = AppLocalName.vonage
    private let skypeForBusiness = AppLocalName.skypeForBusiness
    
    var timer: Timer!
    
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
        // This block of operations will be run in background thread
        // Do not access main thread from within this block
//        let blockOperation = BlockOperation {
            if self.skypeForBusinessApp != nil {
//                while true {
//                    moveWindow()
                self.timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.moveWindow), userInfo: nil, repeats: true)
//                }
            }
//        }
//        backgroundQueue.addOperation(blockOperation)
    }
    
    @objc func moveWindow() {
        guard let skype = self.skypeForBusinessApp else {return}
        if self.activeApp == skype && self.vonageApp != nil {
            self.movementManager.moveWindow(ofAttachedApp: self.vonageApp!, withMasterApp: skype)
        } else if self.activeApp == self.vonageApp {
            self.movementManager.moveWindow(ofMasterApp: skype, withAttachedApp: self.vonageApp)
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
    
    func detachVonageFromSkypeOnSkypeTermination() {
        processObserver.addObserver(forName: NSWorkspace.didTerminateApplicationNotification,
                                    object: nil, // always NSWorkspace
        queue: OperationQueue.main) { [weak self] (notification: Notification) in
            if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.localizedName == self?.skypeForBusiness {
                    p.debugPrint(propertyValue: "Skype app killed")
                    self?.skypeForBusinessApp = nil
                    self?.movementManager.clearOldPositionOfMasterApp()
                    self?.timer.invalidate()
                    self?.backgroundQueue.cancelAllOperations()
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
                    self.timer.invalidate()
                    self.backgroundQueue.cancelAllOperations()
                    CLICommandManager.exitMain()
                }
            }
        }
    }
    
}
