//
//  AnalogDevice.swift
//  GardenController
//
//  Created by Tord Wessman on 15/06/15.
//  Copyright (c) 2015 Axel IT AB. All rights reserved.
//

import Foundation

/** Human readable definition of remote device types. */
public enum AnalogDeviceType: Int {
    
    case undefined = 0
    case humidity = 1
    case servo = 2
    case moist = 3
    case temperature = 4
    case binary = 5
    
}

/** Implementations represents an analogue input port */
public protocol IInputPort {

    var value: Bool {get}
    
}

/** Implementation represents an analogue remote device */
public protocol IAnalogDevice: IDevice {
    
    associatedtype T
    
    var value: T?  {get set}
    var sensorType: AnalogDeviceType {get}
    
}

/** RPC representation of an digital input port */
public class InputPort: IInputPort {
    
    private var m_device: AnalogDevice<Bool>
    
    init (device: AnalogDevice<Bool>) {
        
        m_device = device
        
    }
    
    public var value: Bool {
        
        get { return m_device.value ?? false }
        
    }
    
    public var id: String { get { return m_device.id } }
    
    public var ready: Bool { get { return m_device.ready } }
    
    public func onChange(listener: @escaping (IDevice) -> ()) { m_device.onChange(listener: listener) }
    
    public func update() { m_device.update() }
    
    
}

/** RPC representation of any analogue device. */
public class AnalogDevice<T>: DeviceBase, IAnalogDevice {
    
    private var m_value: T?
    private var m_type: AnalogDeviceType?
    
    public init(id: String, deviceRouter: IDeviceRouter?, type: AnalogDeviceType? = nil) {
        
        super.init(id: id, deviceRouter: deviceRouter)
        m_type = type
        
    }
    
    public var value: T? {
        
        get { return m_value }
        set { deviceRouter?.set(device: self, propertyName: DeviceBase.Value, value: newValue) }
        
    }
    
    public var sensorType: AnalogDeviceType {

        return m_type ?? .undefined

    }
    
    public override func update(json: InputStream.JsonDictionaryType) {
        
        if let object = json.json(key: DeviceModel.Object) {
            
            m_value = object.parse(key: DeviceBase.Value)
            
        }
        
        super.update(json: json)
        
    }

}
