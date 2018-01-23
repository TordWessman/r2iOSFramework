//
//  ASR.swift
//  GardenController
//
//  Created by Tord Wessman on 30/12/16.
//  Copyright © 2016 Axel IT AB. All rights reserved.
//

import Foundation

public protocol IASR: IDevice {
    
    var Active: Bool {get set}
    var Port: Int {get}
    
}

public class ASRServer: DeviceBase, IASR {
    
    private var m_active: Bool!
    private var m_port: Int!
    
    public var Active: Bool {
        get {
            return m_active
        }
        
         set {
            
            deviceRouter?.set(device: self, propertyName: "Active", value: newValue as AnyObject?)
            
        }
    }
    
    public var Port: Int { get { return m_port } }

    public override func update(json: InputStream.JsonDictionaryType) {

        if let object = json.json(key: DeviceModel.Object) {
            
            m_active = object.parse(key: "Active")
            m_port = object.parse(key: "Port")

        }
        
        super.update(json: json)
        
    }
    
    public func update(delegate: ((Bool) -> Void)) {
     
        deviceRouter?.get(device: self)
        
    }
    
}
