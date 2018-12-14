//
//  PrintUtility.swift
//  stickWindow
//
//  Created by Nutan Niraula on 12/14/18.
//  Copyright © 2018 Nutan Niraula. All rights reserved.
//

import Foundation

class PrintUtility {
    
    static func debugPrint<T: CustomDebugStringConvertible>(propertyName name: String = "", propertyValue val: T) {
        if DebugMode.isActive {
            print("DEBUG \(name): \(val.debugDescription)")
        } else {
            //TODO: Remove this print on production
            print("DEBUG print is disabled")
        }
    }
    
}
