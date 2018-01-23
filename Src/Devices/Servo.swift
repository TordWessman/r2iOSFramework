//
//  Servo.swift
//  GardenController
//
//  Created by Tord Wessman on 18/08/15.
//  Copyright (c) 2015 Axel IT AB. All rights reserved.
//

import Foundation

public protocol IServo: IDevice {

    var value: Float? {get set}
    
}

public class Servo: DeviceBase, IServo {
    
    private var m_value: Float?
    
    public var value: Float? {
        
        get { return m_value }
        set { deviceRouter?.set(device: self, propertyName: DeviceBase.Value, value: newValue) }
    }
    
    public override func update(json: InputStream.JsonDictionaryType) {
        
        if let object = json.json(key: DeviceModel.Object) {
        
            m_value = object.parse(key: DeviceBase.Value)
            
        }
        
        super.update(json: json)
            
    }
        
}
