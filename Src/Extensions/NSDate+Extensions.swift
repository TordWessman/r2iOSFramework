//
//  NSDate+Extensions.swift
//  GardenController
//
//  Created by Tord Wessman on 30/06/15.
//  Copyright (c) 2015 Axel IT AB. All rights reserved.
//

import Foundation

extension Date {
    
    func dayName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
    
    func time() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH.mm"
        return dateFormatter.string(from: self)
    }
    
    func timeShort() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        return dateFormatter.string(from: self)
    }
    
    func dayTime() -> String {
        
        let range = dayName().index(dayName().startIndex, offsetBy: 3)
        return dayName().substring(to: range) + " " + self.time()
    }
    
    func dayTimeShort() -> String {
        
        let range = dayName().index(dayName().startIndex, offsetBy: 1)
        return self.dayName().substring(to: range) + self.time()
    }
    
    func dayShort() -> String {
        
        let range = dayName().index(dayName().startIndex, offsetBy: 3)
        return self.dayName().substring(to: range) + self.timeShort()
        
    }
}
