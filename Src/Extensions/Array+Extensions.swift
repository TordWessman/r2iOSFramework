//
//  Array+Json.swift
//  GardenController
//
//  Created by Tord Wessman on 06/11/14.
//  Copyright (c) 2014 Axel IT AB. All rights reserved.
//

import Foundation

extension Array {
    
    /**
    *   Creates an Array containing a dictionary (a JSON representation) of an 
    *   object Array containing BaseModels
    */
    static func json<M: JSONConvertable>(array: Array<M>) -> Array<[String:Any?]>{

        var returnArray: Array<[String:Any?]> = Array<[String:Any?]> ()
        
        for i in 0...array.count  {
            
            let obj = array[i]
            let model: M = obj as M
            returnArray.append(model.json)
            
        }
        
        return returnArray;
    }
    
    /**
    *   Returns true if an object of type T was found in an array
    */
    func contains<T : Equatable>(_ object: T) -> Bool {
        return self.filter({$0 as? T == object}).count > 0
    }
    
    /**
    *   Removes all objects of type T in the array. Returns true
    *   if any object was removed och false otherwise
    */
    mutating func remove<T: Equatable>(object: T) -> Bool {

        if (self.contains(object)) {

            let index = indexOf { $0 == object }
                
            if (index != nil) {
                self.remove(at: index!)
                return true
            }
            
            return false
        }

        return false
    }
    
    /**
    *   Returns the index of an object of type T or nil if not found
    */
    func indexOf<T: Equatable>(object: (T) -> Bool) -> Int? {
        for i in 0...self.count {
            let obj = self[i]
            if object((obj as? T)!) {
                return i
            }
        }
        return nil
    }

}
