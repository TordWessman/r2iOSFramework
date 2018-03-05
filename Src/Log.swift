//
//  Log.swift
//  StupidMeter
//
//  Created by Tord Wessman on 26/10/14.
//  Copyright (c) 2014 Axel IT AB. All rights reserved.
//

import Foundation

public enum R2LogLevel: Int {
    
    case info = 0
    case debug = 1
    case warn = 2
    case error = 3
    
}
/** Simple interface for print log output */
public class Log {
    
    /** Print to console. */
    public class func d(_ what: Any?, _ level: LogLevel.debug) {
        //TODO: implement log level.
        if let v = what {
            print("[\(String(describing: level))] \(String(describing: v))");
        } else {
            print ("nil")
        }
       
    }

}
