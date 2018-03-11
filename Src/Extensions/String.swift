//
//  String.swift
//  StupidMeter
//
//  Created by Tord Wessman on 26/10/14.
//  Copyright (c) 2014 Tord Wessman. All rights reserved.
//

import Foundation

public extension String {
    
    public func localized(comment:String) -> String{
        
        let s = NSLocalizedString(self,comment: comment)
        return s;
    
    }
    
    public var T: String {
        
        get {
            return self.localized(comment: "")
        }
    }
    
    public var asDate: Date? {
        
        //yyyy-MM-dd'T'HH:mm:ssZZZ
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: self)
    
    }
    
    var length: Int { return self.count }
    
    public var trim: String { return self.trimmingCharacters( in: .whitespacesAndNewlines ) }
    
    public func remove(string: String) -> String {
        
        return self.replacingOccurrences(of: string, with: "", options: .literal, range: nil)
    }
    
}
