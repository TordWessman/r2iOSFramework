//
//  IDeviceWebSocketSession.swift
//  GardenController
//
//  Created by Tord Wessman on 15/12/16.
//  Copyright © 2016 Axel IT AB. All rights reserved.
//

import Foundation

/** Responsible for RPC synchronization with a remote host.*/
public protocol IDeviceRouter {

    /** Returns true if the device handler can send and receive data. */
    var ready: Bool { get }
    
    /** The device wants request it's value. If ´delegate´ is set, the response will be returned here. */
    func get (device: IDevice, delegate: InputStream.JsonDictonaryResponseType?)
    
    /** Update the ´propertyName´ and set it to ´value´. If ´delegate´ is set, the response will be returned here. */
    func set(device: IDevice, propertyName: String, value: Any?, delegate: InputStream.JsonDictonaryResponseType?)
    
    /** Invoke remote method namaed `Action` with parameters `parameters`. If ´delegate´ is set, the response will be returned here. */
    func invoke(device: IDevice, action: String, parameters: [Any?], delegate: InputStream.JsonDictonaryResponseType?)
    
    /** Register the device for updates */
    func register (device: IDevice)
    
}

/** Make ´delegate´ optional.
 */
public extension IDeviceRouter  {
    
    public func get (device: IDevice, delegate: InputStream.JsonDictonaryResponseType? = nil) {
        
        get (device: device, delegate: nil)
        
    }
    
    public func set(device: IDevice, propertyName: String, value: Any?, delegate: InputStream.JsonDictonaryResponseType? = nil) {
        
        set (device: device, propertyName: propertyName, value: value, delegate: nil)
        
    }
    
    public func invoke(device: IDevice, action: String, parameters: [Any?], delegate: InputStream.JsonDictonaryResponseType? = nil) {
        
        invoke(device: device, action: action, parameters: parameters, delegate: nil)
        
    }
    
    
}
