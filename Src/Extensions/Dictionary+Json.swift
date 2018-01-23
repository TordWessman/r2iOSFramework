//
//  Dictionary+Json.swift
//  GardenController
//
//  Created by Tord Wessman on 14/06/15.
//  Copyright (c) 2015 Axel IT AB. All rights reserved.
//

import Foundation

/**
*   Enum type where E represents the raw value type of the enumeration (Int, String etc)
*   Any object can conform to this protocol, but an enumeration has the
*   failable init method implicitly declared.
*/
public protocol EnumType {
    associatedtype E = StringInitalizable
    init?(rawValue: E)
    static func defaultValue() -> E
}


/**
*   Contains extension methods for a (Json) Dictionary.
*   Methods must always return a value of the expected type.
*/
public extension Dictionary {

    /**
     *     Tries to parse the value as an URL
     */
    public func url(key: String) -> URL? {
        
        if let value: String = parse(key: key) { return URL(string: value) }
        
        return nil
        
    }
 
    /**
    *   Return an object conforming to protocol EnumType.String (preferably an enumeration)
    */
    public func enumeration<T: EnumType>(key: String) -> T? {
        
        if  let value: T.E = parse(key: key),
            let enumeration: T = T(rawValue: value as T.E) {

            return enumeration
            
        }

        return nil

    }

    /**
    *   Return an array of type T (Int, String, Bool, Dictionary etc)
    */
    public func array<T>(key: String) ->Array<T>? {

        if let value: Array<T> = parse(key: key) { return value }
        
        return nil
        
    }

    /**
    *       Returns a JSON Dictionary
    */
    public func json(key: String) ->Dictionary<String,AnyObject>? {

        if let value: Dictionary<String,AnyObject> = parse(key: key) { return value }
        
        return nil
       
    }
    
    /**
    *   Populatas an array of the given type, T, where T must implement the JSONInitializable protocol.
    */
    public func models<T:JSONInitializable>(key: String) -> Array<T>? {
        
        guard let k = key as? Key else { assertionFailure("\(key) was not of type Key. "); return nil }
        
        let value = self[k]
        
        var returnArray: Array<T> = Array<T>()
        
        if (isNull(value: value)) { return nil }
        
        if let arrayDictionary = value as? Array<[String:AnyObject]> {
     
            for json in arrayDictionary {
                
                if let obj = T(json: json) {
                
                    returnArray.append(obj)
                    
                } else {
                    
                    Log.d("Unable to parse object with json @(json)")
                    
                }

            }
            
            return returnArray
            
        }
        
        return nil
        
    }
    
    /**
    *   Returns an optional T, where T must implement the JSONInitializable protocol.
    */
    public func model<T:JSONInitializable>(key: String) -> T? {
        
        guard let k = key as? Key else { assertionFailure("\(key) was not of type Key. "); return nil }
        
        let value = self[k]
        
        if isNull(value: value) {
            return nil
        }
        
        if let dictionary = value as? [String: AnyObject] { return T(json: dictionary) }
        
        return nil
        
    }

    
    private func isNull(value: Value?) -> Bool{

        return value == nil || value is NSNull || value is NSNull?
        
    }
    
    public func parse<T>(key: String) -> T? {
        
        guard let k = key as? Key else { assertionFailure("\(key) was not of type Key. "); return nil }
        
        if let val = self[k], !isNull(value: val)  {

            return val as? T
            
        }
        
        return nil
    
    }
    
    public func date(key: String) -> Date? {
        
        if let string: String = parse(key: key) {
            
            return string.asDate
            
        }
        
        return nil
        
    }

}
