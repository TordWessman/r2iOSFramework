//
//  TCPMessage.swift
//  gardeny
//
//  Created by Tord Wessman on 03/11/17.
//  Copyright © 2017 Axel IT AB. All rights reserved.
//

import Foundation

public struct TCPMessage {
    
    public var code: Int16
    public var payload: InputStream.JsonDictionaryType
    public var destination: String
    public var headers: InputStream.JsonDictionaryType
    
    // Exposes the init method outside the framework
    public init(code: Int16, payload: InputStream.JsonDictionaryType, destination: String, headers: InputStream.JsonDictionaryType) {
        self.code = code
        self.payload = payload
        self.destination = destination
        self.headers = headers
    }
    
}
