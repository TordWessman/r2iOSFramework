//
//  NSData+Extensions.swift
//  GardenController
//
//  Created by Tord Wessman on 19/08/15.
//  Copyright (c) 2015 Axel IT AB. All rights reserved.
//

import Foundation

extension Data {
    
    var deviceTokenString: String {
        get {
            
            var tokenString = ""
            
            var values = [UInt8](repeating:0, count: self.count)
            self.copyBytes(to: &values, count: self.count)
            
            for i in 0...self.count - 1 {
                tokenString += String(format: "%02.2hhx", arguments: [values[i]])
            }
            
            return tokenString
        }
    }
}
