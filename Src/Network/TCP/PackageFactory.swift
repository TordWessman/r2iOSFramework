//
//  PackageFactory.swift
//  gardeny
//
//  Created by Tord Wessman on 03/11/17.
//  Copyright © 2017 Axel IT AB. All rights reserved.
//

import Foundation

enum NetworkError : Error {
    case SerializationError(String)
    case ConnectionError(String)
    case NoDataError(String)
    case ResponseError(String)
    
}

class PackageFactory {
    
    // This is a constant value defined by the backend, informing that dynamic types (serialized object) is sent to the backend
    private let dynamicType: Int16 = 1
    
    public func serialize(message: TCPMessage) -> Data? {
     
        let code = Data.serialize(message.code)
        let payloadDataType = Data.serialize(dynamicType)
        let destination = [UInt8](message.destination.utf8)
        var payload: [UInt8]?
        var headers: [UInt8]?
        
        do {
        
            try payload = [UInt8](JSONSerialization.data(withJSONObject: message.payload, options: JSONSerialization.WritingOptions()))
            try headers = [UInt8](JSONSerialization.data(withJSONObject: message.headers, options: JSONSerialization.WritingOptions()))
            
        } catch {
            
            Log.d("ERROR: Unable to serialize: \(error)")
            return nil
            
        }
        
        let headerSize = Data.serialize(headers!.count, 4)
        let destinationSize = Data.serialize(destination.count, 4)
        let payloadSize = Data.serialize(payload!.count, 4)
        return Data(bytes: concat(arrays: code, destinationSize, headerSize, payloadSize, destination, headers!, payloadDataType, payload!))
    }
    
    
    public func deserailize(data: Data) -> TCPMessage? {
        
        do {
            
            let s: InputStream = InputStream(data: data)
            s.open()
            let code: Int16 = try s.read(Int16.self)
            let destinationSize: Int32 = try s.read(Int32.self)
            let headerSize: Int32 = try s.read(Int32.self)
            let payloadSize: Int32 = try s.read(Int32.self)
            let destination: String = destinationSize > 0 ? String(data: try s.read(Int(destinationSize)), encoding: .utf8) ?? "" : ""
            let headers: InputStream.JsonDictionaryType = headerSize > 0 ? try s.json(Int(headerSize)) : InputStream.JsonDictionaryType()
            let payloadDataType: Int16 = try s.read(Int16.self) // payloadDataType == self.dynamicType (no other implementations atm).
            var payload: InputStream.JsonDictionaryType = InputStream.JsonDictionaryType()
            
            if (payloadSize > 0) {
                
                switch payloadDataType {
                case dynamicType:
                    payload = try s.json(Int(payloadSize))
                    break
                default:
                    
                    // Try interpret as a string:
                    payload = try ["Data": String(bytes: s.read(Int(payloadSize)), encoding: String.Encoding.utf8) as Any]
                    
                }
                
            }
            
            return TCPMessage(code: code, payload: payload, destination: destination, headers: headers)
            
        } catch {
            
            Log.d("ERROR: Unable to deserialize: \(error)")
            
        }
        
        return nil
        
    }
    
    fileprivate func concat(arrays: [UInt8]...) -> [UInt8] {
        
        var ret: [UInt8] = [UInt8]()
        
        for array in arrays { ret += array }
        
        return ret
    }
    
    
    
}
