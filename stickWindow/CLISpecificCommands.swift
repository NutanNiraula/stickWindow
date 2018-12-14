//
//  CLISpecificCommands.swift
//  stickWindow
//
//  Created by Nutan Niraula on 12/14/18.
//  Copyright © 2018 Nutan Niraula. All rights reserved.
//

import Foundation

struct CLICommandManager {
    
    static func exitMain(withCode code: Int32 = 0) {
        exit(code)
    }
    
    static func runMainWithoutExit() {
        RunLoop.main.run()
    }
    
}

//Exit code guide
//0
//
//No error. The script executed successfully.
//
//-1
//
//A registry key or file required for Command Manager was not found.
//
//1
//
//Command Manager was unable to load and prepare its operating environment.
//
//2
//
//The command line parameters could not be parsed.
//
//3
//
//Your Command Manager license has expired. You can view license information in License Manager.
//
//4
//
//Command Manager was unable to establish a connection to Intelligence Server.
//
//5
//
//Command Manager was unable to establish a connection to Narrowcast Server.
//
//6
//
//The script contained a syntax error.
//
//8
//
//Intelligence Server returned an error.
//
//9
//
//Narrowcast Server returned an error.
//
//10
//
//A file-related operation failed. For example, the script may have tried to write to a read-only file, or read from a file that does not exist.
//
//12
//
//The script contains a statement that is not supported in Command Manager Runtime. For a list of statements available to Command Manager Runtime, see List of statements supported in Command Manager Runtime.
//
//15
//
//The script file is empty.
