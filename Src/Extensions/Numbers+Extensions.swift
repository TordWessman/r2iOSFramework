//
//  Numbers+Extensions.swift
//  GardenController
//
//  Created by Tord Wessman on 15/06/15.
//  Copyright (c) 2015 Axel IT AB. All rights reserved.
//

import Foundation

extension Float {
    var asPercentage:String {
        get {
            return String(format: "%g ", self.roundTo(numberOfDecimals: 2)) + "%"
        }
    }
    
    /**
    *   Rounds to the specified number of decimals
    */
    func roundTo(numberOfDecimals: UInt) ->Float {
        
        return roundTo(numberOfDecimals: UInt(self * pow(10, Float(numberOfDecimals)))) / pow(10, Float(numberOfDecimals))
        
    }
}

extension Double {
    
    func asAccessibilityCurrencyFormat() -> String {
        
        return floor(self).toString + " " + "sek_long".T
    
    }
    
    /**
    *   returns true if part is contained within self (lowercased and as string expression)
    */
    public func has(part: String) -> Bool {
        
        return self.toString.lowercased(with: nil).range(of: part.lowercased(with: nil)) != nil
    
    }
    

    var asPercentage: String {
        
        get {
        
            return String(format: "%g ", self.roundTo(numberOfDecimals: 2)) + "%"
        
        }
    
    }
    
    /**
     *   Rounds to the specified number of decimals
     */
    func roundTo(numberOfDecimals: UInt) -> Double {
        
        return  roundTo(numberOfDecimals: UInt(self *  pow(10.0, Double(numberOfDecimals)))) / pow(10.0, Double(numberOfDecimals))
        
    }
}
