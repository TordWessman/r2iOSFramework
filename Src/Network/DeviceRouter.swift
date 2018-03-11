//
//  DeviceWebSocketSession.swift
//  GardenController
//
//  Created by Tord Wessman on 07/12/16.
//  Copyright © 2016 Axel IT AB. All rights reserved.
//

import Foundation

public class DeviceRouter: CanReceiveSessionData, IDeviceRouter {
    
    public func onSessionError(session: ISocketSession, error: Error?) {
        
        Log.d("\(String(describing: error)) for connection: \(session.address)", .error)
    
    }
    
    // Connection to the remote host
    private var m_session: ISocketSession
    
    // List of all devices connected. <Device identifier: Device representation>
    private var m_devices: [String: IDevice]
    
    public var ready: Bool { return m_session.isConnected }
    
    private var m_endpoint: String
    
    /** Initialize using a ISocketSession representing the connection to the remote host. The ´endpoint´ is the path to the remote host's service (i.e. "/devices") */
    public init(session: ISocketSession, endpoint: String) {
        
        m_session = session
        m_devices = [String: IDevice]()
        m_endpoint = endpoint
        
        m_session.addObserver(observer: self)
        
    }
    
    public func register(device: IDevice) {
        
        m_devices[device.id] = device
        
        if (ready) {
            
            get (device: device)
        
        }
    
    }
    
    public func set(device: IDevice, propertyName: String, value: Any?, delegate: InputStream.JsonDictonaryResponseType? = nil) {
        
        let request = JSONObjectRequest(id: device.id, endpoint: m_endpoint)
        
        request.type = .set
        request.action = propertyName
        request.addParam(value: value)
        
        let _ = m_session.send(model: request) { (response, error) in
            
            delegate?(response, error)
            
        }
        
    }
    
    public func invoke(device: IDevice, action: String, parameters: [Any?], delegate: InputStream.JsonDictonaryResponseType? = nil) {
        
        let request = JSONObjectRequest(id: device.id, endpoint: m_endpoint)
        
        request.type = .invoke
        request.action = action
        
        parameters.forEach{ request.addParam(value: $0) }
        
        m_session.send(model: request) { [weak self] (response, error) in
            
            guard self != nil else {
                
                Log.d("DeviceRouter was nil!")
                
                return
            }
            
            delegate?(response, error)
            
            guard error == nil else {
              
                //TODO onError
                return
                
            }
            
            Log.d(String(describing: response))
            self?.onSessionReceive(session: self!.m_session, response: response ?? InputStream.JsonDictionaryType())
            
        }
        
    }
    
    public func get(device: IDevice, delegate: InputStream.JsonDictonaryResponseType? = nil) {
        
        let request = JSONObjectRequest(id: device.id, endpoint: m_endpoint)
        
        request.type = .get
        
        let _ = m_session.send(model: request) { (response, error) in
            
            delegate?(response, error)
            
        }

    }
    
    public func onSessionReceive(session: ISocketSession, response: InputStream.JsonDictionaryType) {

        if let object = response.json(key: DeviceModel.Object), let id: String = object.parse(key: DeviceModel.Identifier)! {
            
            if let device = m_devices[id] {
                
                device.update(json: response)
                
            }
            
        }

    }
    
    public func onConnect(session: ISocketSession) {
        
        for device in m_devices.values {
            
            get(device: device)
            
        }
        
    }

}
