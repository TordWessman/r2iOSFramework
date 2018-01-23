//
//  UDPClient.swift
//  gardeny
//
//  Created by Tord Wessman on 2017-11-17.
//  Copyright © 2017 Axel IT AB. All rights reserved.
//

import Foundation

public class UDPClient {
    
    public typealias MessageDelegate = (_ response: TCPMessage, _ host: String, _ port: Int)->()
    private let guidHeaderKey = "BroadcastMessageUniqueIdentifier"
    private var m_connection: UDPBroadcastConnection!
    private var m_serializer: PackageFactory!
    private var m_requestDelegates: [String: MessageDelegate]
    
    init (port: UInt16, serializer: PackageFactory) {
        
        m_requestDelegates = [String: MessageDelegate]()
        m_connection = UDPBroadcastConnection(port: port, handler: responseReceived)
        m_serializer = serializer
       
        
    }
    
    public func broadcast(requestMessage: TCPMessage, delegate: MessageDelegate?) {
        
        var message = requestMessage
        
        let guid = UUID().uuidString
        
        m_requestDelegates[guid] = delegate
        
        message.headers[guidHeaderKey] = guid as AnyObject
        
        let serialized = m_serializer.serialize(message: message)!
        
        m_connection.sendBroadcast(serialized)
        
    }
    
    private func responseReceived(address: String, port: Int, data: [UInt8]) {
        
        let response = m_serializer.deserailize(data: Data(bytes: data))
        
        guard let responseGuid = response?.headers[guidHeaderKey] as? String, let delegate = m_requestDelegates[responseGuid] else {
            
            let responseDescription: String = response == nil ? "(unable to parse)" : String(describing: response!.payload) + " GUID " + (response?.headers[guidHeaderKey] as? String ?? "(no message id)")
            
            Log.d("Not for me from \(address):\(port), message id: \(responseDescription)")
            return
            
        }
        
        delegate(response!, address, port)
        
    }
 
}
 
