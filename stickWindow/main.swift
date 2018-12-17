//
//  main.swift
//  stickWindow
//
//  Created by Nutan Niraula on 12/10/18.
//  Copyright © 2018 Nutan Niraula. All rights reserved.
//

import Foundation
import Cocoa

let attachManager = AttachManager(withMovementManager: AppMovementManager(), processObserver: NSWorkspace.shared.notificationCenter)
attachManager.assignActiveApps()
attachManager.attachVonageToSkypeOnLaunchingVonage()
attachManager.attachVonageWindowToSkypeIfSkypeIsLaunched()
attachManager.attachVonageToSkypeOnLaunchingSkype()
attachManager.detachVonageFromSkypeOnSkypeTermination()
attachManager.exitOnVonageTermination()
attachManager.observeActiveApp()

CLICommandManager.runMainWithoutExit()

