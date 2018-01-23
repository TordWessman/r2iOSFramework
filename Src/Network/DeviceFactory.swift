//
//  DeviceFactory.swift
//  GardenController
//
//  Created by Tord Wessman on 22/08/15.
//  Copyright (c) 2015 Axel IT AB. All rights reserved.
//

import Foundation

public class DeviceFactory {
    
    private var m_deviceRouter: IDeviceRouter
    
    init (deviceRouter : IDeviceRouter ) {
            m_deviceRouter = deviceRouter
    }
    
    func CreateVoice(id: String) -> IVoice {
    
        let voice = Voice(id: id, deviceRouter: m_deviceRouter)
        m_deviceRouter.get(device: voice)
        return voice
        
    }
    
    func CreateInputPort(id: String) -> IInputPort {
 
        let device = AnalogDevice<Bool>(id: id, deviceRouter: m_deviceRouter)
        m_deviceRouter.get(device: device)
        return InputPort(device: device)
        

        
    }
    
    func CreateOutputPort(id: String) -> AnalogDevice<Bool> {
        
        let device = AnalogDevice<Bool>(id: id, deviceRouter: m_deviceRouter)
        m_deviceRouter.get(device: device)
        return device
        
    }
    
    func CreateSensor<T>(id: String) -> AnalogDevice<T> {
        
        let sensor = AnalogDevice<T>(id: id, deviceRouter: m_deviceRouter)
        m_deviceRouter.get(device: sensor)
        return sensor
        
    }
    
    func createConsole(id: String) -> IConsole {
        let console = Console(id: id, deviceRouter: m_deviceRouter)
        //m_deviceRouter.
        return console
        
    }
    
    func createRemoteLog(id: String) -> IRemoteLog {
        
        return RemoteLog(id: id, deviceRouter: m_deviceRouter)
        
    }
    
    func createServo(id: String) -> IServo {
        
        let servo = Servo(id: id, deviceRouter: m_deviceRouter)
        return servo
        
    }
    
}
