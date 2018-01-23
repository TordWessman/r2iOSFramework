//
//  DeviceBase.swift
//  GardenController
//
//  Created by Tord Wessman on 18/12/16.
//  Copyright © 2016 Axel IT AB. All rights reserved.
//

import Foundation

/*! Convenience base class for devices. Helps with common functionality. */
public class DeviceBase: IDevice {
    
    public typealias DEVICE_CHANGED = (IDevice) -> ()
    
    public static let Value = "Value"
    
    private(set) public var id: String
    private(set) var deviceRouter: IDeviceRouter?
    
    private var m_listeners: Array<DEVICE_CHANGED>
    private var m_initalized: Bool
    private var m_deviceReady: Bool
    
    public var ready: Bool {
        
        return m_initalized && (deviceRouter?.ready == true) && m_deviceReady
    
    }
    
    public init(id: String, deviceRouter: IDeviceRouter?) {
        
        self.id = id
        self.deviceRouter = deviceRouter
        
        m_listeners = Array<DEVICE_CHANGED>()
        m_initalized = false
        m_deviceReady = false
        
        self.deviceRouter?.register(device: self)
    }
    
    public func update(json: InputStream.JsonDictionaryType) {
    
        m_initalized = true
        m_deviceReady = json.json(key: DeviceModel.Object)?.parse(key: DeviceModel.Ready) ?? false
        
        notifyChange()
        
    }

    public func onChange(listener: @escaping DEVICE_CHANGED) {
        
        m_listeners.append(listener)
        
    }
    
    public func update() {
        
        if deviceRouter?.ready == true {
            
            deviceRouter?.get(device: self)

        }
    }
    
    internal func notifyChange() {
        
        DispatchQueue.global(qos: .background).async { [weak self] in

            guard self != nil else { return; }
            
             self!.m_listeners.forEach {$0(self!)}
            
        }

    }
    
}
