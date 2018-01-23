//
//  Log.swift
//  StupidMeter
//
//  Created by Tord Wessman on 26/10/14.
//  Copyright (c) 2014 Axel IT AB. All rights reserved.
//

import Foundation

class Log {
    
    class func d(_ what: Any?) {
        if let v = what {
            print(v);
        } else {
            print ("nil")
        }
       
    }

}
