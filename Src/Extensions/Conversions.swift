//
//  String+Conversion.swift
//  GardenController
//
//  Created by Tord Wessman on 27/08/15.
//  Copyright (c) 2015 Axel IT AB. All rights reserved.
//

import Foundation

public protocol StringInitalizable {

    init?(usingString: String)

}

public protocol StringConvertable {
    
    var toString: String { get }
    
}

public protocol AsString: StringInitalizable, StringConvertable {

    
   
    
}

extension String: AsString {
    
    public var toString: String { return self }
    
    public init?(usingString: String) { self = usingString }
    
}

enum StringConversionTypes: Int {
    case Float = 0
}

extension Float : Initializable {}

public protocol Initializable {
    init()
}

extension UInt: AsString {
    
    public var toString: String { return String (self) }
    
    public init?(usingString: String) {
        
        guard let this = UInt(usingString) else {
            return nil
        }
        
        self = this
    }
    
}

extension Int: AsString {
    
    public var toString: String { return String (self) }
    
    public init?(usingString: String) {
        
        guard let this = Int(usingString) else {
            return nil
        }
        
        self = this
    }
    
}

extension Bool: AsString {
    
    public var toString: String { return String (self) }
    
    public init?(usingString: String) {
        
        guard let this = Bool(usingString) else {
            return nil
        }
        
        self = this
    }
    
}

extension Double: AsString {
    
    public var toString: String {
        
        return String(format: "%g", self)
        
    }
    
    public init?(usingString: String) {
        
        guard let this = Double(usingString) else {
            return nil
        }
        
        self = this
    }
    
}

extension Float: AsString {
    
    public var toString: String {
        
        return String(format: "%g", self)
    }
    
    public init?(usingString: String) {
        
        guard let this = Float(usingString) else {
            return nil
        }
        
        self = this
    }
    
}

extension Array : AsString {
    
    public var toString:  String {
        var returnString:String = ""
        
        for (obj) in self {
            if let strVal = obj as? AsString {
                returnString = returnString + "["  + strVal.toString + "]"
            }
        }
        
        return " " + returnString + " "
    }
    
    public init?(usingString: String) {
        
        //TODO: create this
        
        return nil
        
    }

}

func unwrap(any:Any) -> Any {
    
    let mi = Mirror(reflecting: any)
    if mi.displayStyle != .optional {
        return any
    }
    
    if mi.children.count == 0 { return NSNull() }
    let (_, some) = mi.children.first!
    return some
    
}
