//
//  NetworkError.swift
//  r2ProjectTests
//
//  Created by Tord Wessman on 2018-03-11.
//  Copyright © 2018 Axel IT AB. All rights reserved.
//

import Foundation

/** Netwokring error types. */
enum NetworkError: Error {
    
    /** Caused by serialization/deserialization issues. */
    case SerializationError(String)
    
    /** Errors caused by (unexpected) bad connectivity. */
    case ConnectionError(String)
    
    /** Data was missing unexpectedly. */
    case NoDataError(String)
    
    /** Server responded with an unexpected response code. */
    case ResponseError(String)
    
}
