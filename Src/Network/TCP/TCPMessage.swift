//
//  TCPMessage.swift
//  gardeny
//
//  Created by Tord Wessman on 03/11/17.
//  Copyright © 2017 Axel IT AB. All rights reserved.
//

import Foundation

/** Represents the communication structure used by any raw network implementation (currently TCP and UDP). The protocol's structure mimics a HTTP request structure in order to allow higher layer communication implementations to communicate using i.e. HTTP and raw TCP interchangeable. */
public struct TCPMessage {
    
    /** Message code. This is usually a response code retrieved from the server. */
    public var code: Int16
    /** Mssage body. */
    public var payload: InputStream.JsonDictionaryType
    /** Mimics the path component of an URL (allowing interchangeability between raw network (i.e. TCP) and HTTP) */
    public var destination: String
    /** Mimics the header fields of an HTTP request. */
    public var headers: InputStream.JsonDictionaryType

    public init(code: Int16, payload: InputStream.JsonDictionaryType, destination: String, headers: InputStream.JsonDictionaryType) {
        self.code = code
        self.payload = payload
        self.destination = destination
        self.headers = headers
    }
    
}
