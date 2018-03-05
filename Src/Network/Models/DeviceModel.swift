//
//  DeviceModel.swift
//  GardenController
//
//  Created by Tord Wessman on 26/12/16.
//  Copyright © 2016 Axel IT AB. All rights reserved.
//

import Foundation

public enum ActionType: Int {
    
    case get = 0
    case set = 1
    case invoke = 2
    
}

public enum ParamType: Int {
    case int = 0
    case float = 1
    case string = 2
    case null = 3
}

public struct Param {
    
    public var rawValue: Any?
    public var type: ParamType
    
    public init(rawValue: Any?, type: ParamType) {
        self.rawValue = rawValue
        self.type = type
    }
    
    public init?(value: Any?) {
        
        guard value != nil else {
            
            rawValue = nil
            type = .null
            return
            
        }
        
        rawValue = value
        
        if let _: String = rawValue as? String {
            type = .string
        }
        else if let _: Int = rawValue as? Int {
            type = .int
        }
        else if let _: Float = rawValue as? Float {
            type = .float
        }
        else if let _: Double = rawValue as? Double {
            type = .float
        }
        else {
            return nil
        }
        
    }
    
}

/** Protocol definition of the subject of a device during RPC communication. */
public final class DeviceModel: JSONObjectRequest {
    
    /** Contains the object representation in JSON format. */
    private(set) public var object: [String:AnyObject]?
    
    // Type of action (i.e Get, Invoke, Set)
    public static let ActionType = "ActionType"
    // Name of the method/property to invoke
    public static let Action = "Action"
    // The response of an Action
    public static let ActionResponse = "ActionResponse"
    // Identifier of the object to invoke
    public static let Identifier = "Identifier"
    // Parameters used by invocation
    public static let Params = "Params"
    // Property containing the target object
    public static let Object = "Object"
    
    // IDevice property.
    public static let Ready = "Ready"
    
    public init (id: String, type: ActionType? = nil, endpoint: String) {
    
        super.init(id: id, endpoint: endpoint)
        self.type = type ?? .get
       
    }
    
    public init? (json: [String:AnyObject]?) {
        
        if let object = json?.json(key: DeviceModel.Object), let id: String = object.parse(key: DeviceModel.Identifier) {
        
            super.init(id: id, endpoint: nil)
            self.object = object
            
        } else {
            
            return nil
            
        }
        
    }
    
}

/** RPC request model used to invoke a DeviceModel */
public class JSONObjectRequest: JSONRequest {
    
    public var type: ActionType?
    public var action: String?
    
    private var m_id: String
    private var m_params: [Param]
    private var m_endpoint: String?
    
    public init (id: String, endpoint: String? = nil) {
        
        m_id = id
        m_params = [Param]()
        m_endpoint = endpoint
    }
    
    public var url: String { return m_endpoint ?? ""}
    
    public var json: InputStream.JsonDictionaryType {
        
        var response: InputStream.JsonDictionaryType = InputStream.JsonDictionaryType()
        
        response[DeviceModel.Identifier] = m_id
        response[DeviceModel.ActionType] = type?.rawValue
        response[DeviceModel.Action] = action
        
        
        if m_params.count > 0 {
            
            var responseParams = [Any?]()
            
            m_params.forEach { responseParams.append($0.rawValue) }
            
            response[DeviceModel.Params] = responseParams
            
        }
        
        return response
        
    }
    
    public func addParam(value: Any?, type: ParamType? = nil) {
        
        if type != nil { m_params.append(Param (rawValue: value, type: type!))  }
        else {
            
            if let param: Param = Param(value: value) {
                
                m_params.append(param)
                
            } else {
                
                let errorMessage = "Unable to determine type of " + String(describing: Mirror(reflecting: value!).subjectType)
                NSException(name: NSExceptionName(rawValue: "Unable to determine parameter type!"), reason: errorMessage, userInfo: nil).raise()
                
            }
            
        }
        
    }
    
}
