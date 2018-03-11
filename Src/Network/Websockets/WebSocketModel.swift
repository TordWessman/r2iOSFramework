//
//  WebSocket.swift
//  GardenController
//
//  Created by Tord Wessman on 04/01/17.
//  Copyright © 2017 Axel IT AB. All rights reserved.
//

import Foundation

/** Represents a remote web socket server. Currently broken on the server side... */
public class WebSocketServerModel: JSONRequest, JSONInitializable {
    
    private(set) public var id: String
    private(set) public var ip: String?
    private(set) public var port: Int?
    private(set) public var ready: Bool
    private var m_token: String?
    
    private(set) public var url: String
    
    required public init? (json: InputStream.JsonDictionaryType?) {
    
        if let object = json!.json(key: DeviceModel.Object), let id: String = object.parse(key: DeviceModel.Identifier) {
            
            self.id = id
            self.url = ""
            self.ready = object.parse(key: DeviceModel.Ready) ?? false
            self.ip = object.parse(key: "Address")
            self.port = object.parse(key: "Port")

        } else {
            
            return nil
        }

    }
    
    public init(id: String, endpoint: String, token: String? = nil) {
        self.id = id
        self.url = endpoint
        m_token = token
        self.ready = false
    }
    
    public var json: InputStream.JsonDictionaryType {
        
        return [DeviceModel.Identifier: id, "Token": m_token ?? "", DeviceModel.ActionType : 0]
        
    }
    
    
}
