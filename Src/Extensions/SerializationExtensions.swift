//
//  InputStream+Extensions.swift
//  r2ProjectTests
//
//  Created by Tord Wessman on 2018-03-07.
//  Copyright © 2018 Axel IT AB. All rights reserved.
//

import Foundation

/** Provides mechanisms for reading out data of a specified length or a JsonDictionaryType object.   */
public extension InputStream {
    
    public typealias JsonDictionaryType = [String: Any]
    public typealias JsonDictonaryResponseType = ((InputStream.JsonDictionaryType?, Error?) -> ())
    
    /** Reads size bytes and deserializes inte a json object */
    func json (_ size: Int) throws -> JsonDictionaryType {
        
        guard let dd = try JSONSerialization.jsonObject(with: read(size), options: JSONSerialization.ReadingOptions.mutableContainers) as? JsonDictionaryType else {
            
            throw NetworkError.SerializationError("Object not of type 'JsonDictionaryType'.")
            
        }
        
        return dd
        
    }
    
    /** Reads count bytes and returns an allocated Data object */
    func read (_ count: Int) throws -> Data {
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
        
        defer {
            
            //buffer.deallocate(capacity: count)
            
        }
        
        let bytesRead = read(buffer, maxLength: count)
        
        guard bytesRead == count else {
            
            throw NetworkError.SerializationError("Stream reading error. Expected \(count) bytes. Got \(bytesRead).")
            
        }
        
        let d = Data(bytes: buffer, count: count)
        
        let s = String(bytes: d, encoding: String.Encoding.utf8)
        print(s!)
        return d
        
    }
    
    /** Reads and returns the type T assuming data is LSB-first structured. */
    func read<T> (_: T.Type) throws -> T {
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: MemoryLayout<T>.size)
        
        let bytesRead = read(buffer, maxLength: MemoryLayout<T>.size)
        guard bytesRead == MemoryLayout<T>.size else {
            
            throw NetworkError.SerializationError("Stream reading error. Expected \(MemoryLayout<T>.size) bytes. Got \(bytesRead).")
            
        }
        
        return buffer.withMemoryRebound(to: T.self, capacity: MemoryLayout<T>.size) { $0.pointee }
        
    }
    
}

/** Provides mechanisms for serialization of value types into byte arrays. */
internal extension Data {
    
    static func serializeObject(_ jsonObject: InputStream.JsonDictionaryType) -> [UInt8]? {
        
        do {
        
            return try [UInt8](JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()))
            
        } catch {
            
            print(error)
            
        }
        
        return nil
        
    }

    /** Transforms the value of the primitive value type T into a raw byte array (LSB first).
     This methods does not apply for complex objects.
     
     */
    static func serializeValue<T>(_ value: T,  count: Int? = nil) -> [UInt8] {
        
        var value: T = value
        
        var array: [UInt8] = withUnsafePointer(to: &value) {
            
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<T>.size) {
                
                Array(UnsafeBufferPointer(start: $0, count: MemoryLayout<T>.size))
                
            }
            
        }
        
        return Array(array[0..<(count ?? MemoryLayout<T>.size)])
    }
    
}
