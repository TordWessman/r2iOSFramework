//
//  TCPSession.swift
//  gardeny
//
//  Created by Tord Wessman on 15/06/17.
//  Copyright © 2017 Axel IT AB. All rights reserved.
//

import Foundation

public class TCPSession: ISocketSession {
    
    private var m_serializer: PackageFactory
    private var m_client: TcpClient!
    private var m_observers: [CanReceiveSessionData]
    
    /** If set, the server will try to reconnect using this interval upon disconnection. */
    public var reconnectionInterval: Int? {
        
        didSet {
            
        }
    }
    
    /** The endpoint address of this session. */
    public var address: String { return m_client.host }
    
    /** Returns true if connection is established to host. */
    public var isConnected: Bool { return m_client.isConnected }
    
    public init(address: String, port: Int) {
    
        m_client = TcpClient(host: address, port: port)
        m_observers = [CanReceiveSessionData]()
        m_serializer = PackageFactory()
        
    }
    
    public func connect(_ delegate: ((Bool) -> ())? = nil) {

        m_client.connect { [weak self] (success, error) in
            
            delegate?(success)
            
            if (!success) {
                
                Log.d("Unabel to connect to \(String(describing: (self?.address ?? "null"))). Error: \((error?.localizedDescription ?? "null"))")
                self?.m_observers.forEach({ (observer) in observer.onSessionError(session: self!, error: error) })
                
            } else {
                
                Log.d("Successfully connected to host.")
                self?.m_observers.forEach({ (observer) in observer.onSessionConnect(session: self!) })
                    
            }
        }
        
    }
    
    public func disconnect() {  m_client.disconnect() }
    
    public func addObserver(observer: CanReceiveSessionData) {
        
        m_observers.append(observer)
        
    }

    public func send(model: JSONRequest, delegate: InputStream.JsonDictonaryResponseType?) {
    
        let requestMessage = TCPMessage(code: 0, payload: model.json as InputStream.JsonDictionaryType, destination: model.url, headers: model.headers as InputStream.JsonDictionaryType)
        
        guard let requestData =  m_serializer.serialize(message:  requestMessage) else { return assertionFailure("Unable to serialize message for destination: \(model.url)") }

        guard m_client.isReady else { return assertionFailure("Unable to send message to destination: \(model.url). Client: \(m_client.description)") }

        m_client.send(data: requestData, delegate: { [weak self] (responseData, error) in
            
            guard error == nil else {
                
                delegate?(nil, error)
                self?.m_observers.forEach({ (observer) in observer.onSessionError(session: self!, error: error) })
                
                return
            }
            guard let responseData = responseData else {
                
                let error = NetworkError.NoDataError("TCPSession send error: no data received. \(requestMessage.destination)")
                delegate?(nil, error)
                self?.m_observers.forEach({ (observer) in observer.onSessionError(session: self!, error: error) })
                
                return
            }
            
            guard let responseMessage = self?.m_serializer.deserailize(data: responseData) else {
                
                let error = NetworkError.SerializationError("TCPSession send error: Unable to deserialize response. \(requestMessage.destination)")
                delegate?(nil, error)
                self?.m_observers.forEach({ (observer) in observer.onSessionError(session: self!, error: error) })
                
                return
                
            }
            
            guard responseMessage.code == 200 else {
                
                let error = NetworkError.ResponseError("Bad response code: \(responseMessage.code) payload: \(String(describing: responseMessage.payload))")
                delegate?(nil, error)
                self?.m_observers.forEach({ (observer) in observer.onSessionError(session: self!, error: error) })
                
                return
                
            }
            
            Log.d("Got response from \(self?.m_client.host ?? ""). Data: \(responseMessage.payload)")
            self?.m_observers.forEach({ (observer) in observer.onSessionReceive(session: self!, response: responseMessage.payload) })
            
            delegate?(responseMessage.payload, nil)

        })

        
    }
    
}
