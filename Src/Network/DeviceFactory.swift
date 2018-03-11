//
//  DeviceFactory.swift
//  GardenController
//
//  Created by Tord Wessman on 22/08/15.
//  Copyright (c) 2015 Axel IT AB. All rights reserved.
//

import Foundation

/** Should be used when creating IDevice implementation. Will update the device (retrieving it's initial values) from remote upon device creation. */
public class DeviceFactory {
    
    private var m_deviceRouter: IDeviceRouter
    
    public init (deviceRouter : IDeviceRouter ) {
            m_deviceRouter = deviceRouter
    }
    
    public func createVoice(id: String) -> IVoice {
    
        let voice = Voice(id: id, deviceRouter: m_deviceRouter)
        m_deviceRouter.get(device: voice)
        return voice
        
    }
    
    public func createInputPort(id: String) -> IInputPort {
 
        let device = AnalogDevice<Bool>(id: id, deviceRouter: m_deviceRouter)
        m_deviceRouter.get(device: device)
        return InputPort(device: device)
        

        
    }
    
    public func createOutputPort(id: String) -> AnalogDevice<Bool> {
        
        let device = AnalogDevice<Bool>(id: id, deviceRouter: m_deviceRouter)
        m_deviceRouter.get(device: device)
        return device
        
    }
    
    public func createSensor<T>(id: String) -> AnalogDevice<T> {
        
        let sensor = AnalogDevice<T>(id: id, deviceRouter: m_deviceRouter)
        m_deviceRouter.get(device: sensor)
        return sensor
        
    }
    
    public func createConsole(id: String) -> IConsole {
        let console = Console(id: id, deviceRouter: m_deviceRouter)
        //m_deviceRouter.
        return console
        
    }
    
    public func createRemoteLog(id: String) -> IRemoteLog {
        
        return RemoteLog(id: id, deviceRouter: m_deviceRouter)
        
    }
    
    public func createServo(id: String) -> IServo {
        
        let servo = Servo(id: id, deviceRouter: m_deviceRouter)
        return servo
        
    }
    
}
