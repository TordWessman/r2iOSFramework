//
//  ASR.swift
//  GardenController
//
//  Created by Tord Wessman on 30/12/16.
//  Copyright © 2016 Axel IT AB. All rights reserved.
//

import Foundation

/** Represents an interface for an asynchronous speach recognition service. Implementations mainly used to expose the port to which the speech service can connect. */
public protocol IASR: IDevice {
    
    /** Is True if the remote ASR is running. */
    var Active: Bool {get set}
    /** The listening port of the ASR. */
    var Port: Int {get}
    
}

/** RPC bridge implementet at the r2Project server. Remote endpoint should be able to receive audio data. */
public class ASRServer: DeviceBase, IASR {
    
    let ActiveCommand = "Active"
    let PortCommand = "Port"
    
    private var m_active: Bool!
    private var m_port: Int!
    
    public var Active: Bool {
        get {
            return m_active
        }
        
         set {
            
            deviceRouter?.set(device: self, propertyName: ActiveCommand, value: newValue as AnyObject?)
            
        }
    }
    
    public var Port: Int { get { return m_port } }

    public override func update(json: InputStream.JsonDictionaryType) {

        if let object = json.json(key: DeviceModel.Object) {
            
            m_active = object.parse(key: ActiveCommand)
            m_port = object.parse(key: PortCommand)

        }
        
        super.update(json: json)
        
    }
    
    public func update(delegate: ((Bool) -> Void)) {
     
        deviceRouter?.get(device: self)
        
    }
    
}
