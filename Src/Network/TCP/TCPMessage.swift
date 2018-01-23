//
//  TCPMessage.swift
//  gardeny
//
//  Created by Tord Wessman on 03/11/17.
//  Copyright © 2017 Axel IT AB. All rights reserved.
//

import Foundation

public struct TCPMessage {
    
    var code: Int16
    var payload: InputStream.JsonDictionaryType
    var destination: String
    var headers: InputStream.JsonDictionaryType
    
}
