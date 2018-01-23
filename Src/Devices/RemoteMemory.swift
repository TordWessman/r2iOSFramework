//
//  Memory.swift
//  GardenController
//
//  Created by Tord Wessman on 21/08/15.
//  Copyright (c) 2015 Axel IT AB. All rights reserved.
//

import Foundation
/*
public class RemoteMemory : IRemoteIODevice {
    
    typealias T = String
    public typealias OPERATION = (String?) ->Void;

    private var m_session: Session
    private var m_name:String
    private var m_id:String?
    
    public var value: String {
        get {
            return m_name
        }
    }
    private(set) var `Type`:String
    private(set) var HasData:Bool
    
    public init (type:String, session:Session, value:String? = nil) {
        m_session = session
        Type = type
        
        HasData = false
        
        if (value == nil) {
            m_name = ""
        } else {
            m_name = value!
        }
    }
    
    public func fetch(operation callback: @escaping OPERATION) {
        
        if (m_session.IsOnline) {
            
            sendToServer(
                updateModel: DeviceModel (
                    token: m_session.token,
                    device: "memory",
                    function: "get_first",
                    params:Type), callback:
            callback)
            
            

            
        }
    }
    
    private var deviceRequest: ModelRequest<DeviceModel>?
    
    private func sendToServer(updateModel: DeviceModel, callback: OPERATION?) {
        
        deviceRequest = m_session.facade.post(params: updateModel).success {
            (model, headers) -> Void in
            
            
            if (model.Data != nil) {
                self.m_name = model.Data!
                self.HasData = true
                if(callback != nil) {
                     callback!(self.m_name)
                }
               
            } else {
                self.HasData = false
                if(callback != nil) {
                    callback!(nil)
                }
                
            }
            
            }.fail { (fail) -> Void in
                self.HasData = false
                if(callback != nil) {
                    callback!(nil)
                }
        }
    }

    
    public func  set (value:String, operation callback: OPERATION? = nil) {
        
        if (m_session.IsOnline) {
            
            if (m_id == nil) {
                sendToServer(updateModel: DeviceModel (
                    token: m_session.token,
                    device: "memory",
                    function: "set",
                    params:Type + "," + value), callback: callback)
            }
           
            
            
        }
    }

}
*/
