//
//  BaseModel.swift
//  StupidMeter
//
//  Created by Tord Wessman on 26/10/14.
//  Copyright (c) 2014 Axel IT AB. All rights reserved.
//

import Foundation

/** Implementations can contain headers. */
public protocol ContainsHeaders {
    
    /** Optional. Returns header/metadata. */
    var headers: [String: String] {get}
    
}

public extension ContainsHeaders {
    
    /** Default implementation. */
    public var headers : [String: String] { return [:] }
    
}

/** Implementations knows how to convert it's data to JSON. */
public protocol JSONConvertable {
    
    var json: InputStream.JsonDictionaryType {get}
    
}

/** Implementations are models eligible for JSON requests. */
public protocol JSONRequest: JSONConvertable, ContainsHeaders {
    
    var url: String {get}
    

}

/** Implementations knows how to initialize using a JSON dictionary. */
public protocol JSONInitializable {
    
    init? (json: InputStream.JsonDictionaryType?)
    
}

