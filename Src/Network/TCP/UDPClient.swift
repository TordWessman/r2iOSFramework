//
//  UDPClient.swift
//  gardeny
//
//  Created by Tord Wessman on 2017-11-17.
//  Copyright © 2017 Axel IT AB. All rights reserved.
//

import Foundation

/** Primitive UDP Broadcasting services. */
public class UDPClient {
    
    /** A Message delegate is the closure returned from a broadcast. */
    public typealias MessageDelegate = (_ response: TCPMessage, _ host: String, _ port: Int)->()
    private let guidHeaderKey = "BroadcastMessageUniqueIdentifier"
    private var m_connection: UDPBroadcastConnection!
    private var m_serializer: PackageFactory!
    private var m_requestDelegates: [String: MessageDelegate]
    
    //TODO: add timeout for requests!!!!
    
    public init (port: UInt16) {
        
        m_requestDelegates = [String: MessageDelegate]()
        m_connection = UDPBroadcastConnection(port: port, handler: responseReceived)
        m_serializer = PackageFactory()
       
        
    }
    
    /** Will broadcast a TCPMessage to the network (underlying UDPClient limits netmask 255.255.255.0).
        The delegate will be called upon success, but there's no guarantee it will, if no host replies.
     
     */
    public func broadcast(requestMessage: TCPMessage, delegate: MessageDelegate?) {
        
        var message = requestMessage
        
        let guid = UUID().uuidString
        
        m_requestDelegates[guid] = delegate
        
        message.headers[guidHeaderKey] = guid as AnyObject
        
        let serialized = m_serializer.serialize(message: message)!
        
        m_connection.sendBroadcast(serialized)
        
    }
    
    // Will be called whenever the underlying UDP client receives any response. Using the primitive [guidHeaderKey] in the header fields to distinguish different delegates.
    private func responseReceived(address: String, port: Int, data: [UInt8]) {
        
        guard let response = m_serializer.deserailize(data: Data(bytes: data)) else {
            
            return assertionFailure("Unable to parse UDP response from \(address).")
        
        }
        
        guard let responseGuid = response.headers[guidHeaderKey] as? String, let delegate = m_requestDelegates[responseGuid] else {
            
            let responseDescription: String = String(describing: response.payload) + " GUID " + (response.headers[guidHeaderKey] as? String ?? "(no message id)")
            
            Log.d("Not for me from \(address):\(port), message id: \(responseDescription)")
            return
            
        }
        
        delegate(response, address, port)
        
    }
 
}
 
