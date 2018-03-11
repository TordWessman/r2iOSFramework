//
//  PackageFactory.swift
//  gardeny
//
//  Created by Tord Wessman on 03/11/17.
//  Copyright © 2017 Axel IT AB. All rights reserved.
//

import Foundation

/**

 Responsible for serialization/deserialization of raw bytes into/from TCPMessage.
 
 TCP protocol format:
 
 Name                   Data type                       Size (in bytes)
 ----------------------------------------------------------------------------
 [Code]:                Int16                           2
 [Destination size]:    Int32                           4
 [Header size]:         Int32                           4
 [Payload size]:        Int32                           4
 [Destination]:         UTF-8 encoded string            (Variable, depending on [Destination size])
 [Headers]:             JSON-serialized dictionary      (Variable, depending on [Header size])
 [Payload]:             JSON-serialized object          (Variable, depending on [Payload size])
 
 */
internal class PackageFactory {
    
    // This is a constant value defined by the backend, informing that dynamic types (serialized object) is sent to the backend
    private let dynamicType: Int16 = 1
    
    /** Serialize a TCPMessage into a raw Data representation conforming to our protocol. */
    public func serialize(message: TCPMessage) -> Data? {
     
        let code = Data.serializeValue(message.code)
        let payloadDataType = Data.serializeValue(dynamicType)
        let destination = [UInt8](message.destination.utf8)

        guard let payload = Data.serializeObject(message.payload), let headers = Data.serializeObject(message.headers) else {
      
            Log.d("ERROR: Unable to serialize.")
            return nil
            
        }
        
        let headerSize = Data.serializeValue(headers.count, count: 4)
        let destinationSize = Data.serializeValue(destination.count, count: 4)
        let payloadSize = Data.serializeValue(payload.count, count: 4)
        return Data(bytes: concat(arrays: code, destinationSize, headerSize, payloadSize, destination, headers, payloadDataType, payload))
    }
    
    /** Tries to deserialize the package as a TCPMessage. The data must form to our protocol. */
    public func deserailize(data: Data) -> TCPMessage? {
        
        do {
            
            let s: InputStream = InputStream(data: data)
            s.open()
            
            // Deserialize the message code...
            let code: Int16 = try s.read(Int16.self)
            // ...the size of the destination string...
            let destinationSize: Int32 = try s.read(Int32.self)
            // ...the size of the (serialized) headers...
            let headerSize: Int32 = try s.read(Int32.self)
            // ...the size of the (serialized) payload...
            let payloadSize: Int32 = try s.read(Int32.self)
            // ...the destination string (as a UTF-8 encoded string)...
            let destination: String = destinationSize > 0 ? String(data: try s.read(Int(destinationSize)), encoding: .utf8) ?? "" : ""
            // ...the headers...
            let headers: InputStream.JsonDictionaryType = headerSize > 0 ? try s.json(Int(headerSize)) : InputStream.JsonDictionaryType()
            // ...the data type for the payload...
            let payloadDataType: Int16 = try s.read(Int16.self)
            
            var payload: InputStream.JsonDictionaryType = InputStream.JsonDictionaryType()
            // ... and finally the payload:
            
            if (payloadSize > 0) {
                
                switch payloadDataType {
                   
                // Dynamic type; the message is a JSON-serialized message.
                case dynamicType:
                    
                    payload = try s.json(Int(payloadSize))
                    break
                    
                default:
               
                    // Try interpret as a string.
                    payload = try ["Data": String(bytes: s.read(Int(payloadSize)), encoding: .utf8) as Any]
                    
                }
                
            }
            
            return TCPMessage(code: code, payload: payload, destination: destination, headers: headers)
            
        } catch {
            
            Log.d("ERROR: Unable to deserialize: \(error)")
            
        }
        
        return nil
        
    }
    
    /** Concatinates a series of byte arrays. */
    fileprivate func concat(arrays: [UInt8]...) -> [UInt8] {
        
        var ret: [UInt8] = [UInt8]()
        
        for array in arrays { ret += array }
        
        return ret
        
    }
    
}
