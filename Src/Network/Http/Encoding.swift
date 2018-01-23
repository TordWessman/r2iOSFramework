//
//  Encoding.swift
//  GardenController
//
//  Created by Tord Wessman on 09/11/15.
//  Copyright © 2015 Axel IT AB. All rights reserved.
//

import Foundation

public extension String {
    var asHttpMethod: HttpMethod? {
        get {
            return HttpMethod(rawValue: self)
        }
    }
}

public struct Encoding {
    
    /**
     *   Returns a new, encoded NSMutableURLRequest using the specified parameter objects and the original request.
     */
    public static func createEncodedRequest(request:NSMutableURLRequest, parameters:[String: Any?]?) -> NSMutableURLRequest? {
        
        if parameters == nil {
            return request        }
        
        if (encodesParametersInURL(method: request.httpMethod.asHttpMethod!)) {
            if let URLComponents = NSURLComponents(url: request.url!, resolvingAgainstBaseURL: false) {
                URLComponents.percentEncodedQuery = (URLComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters: parameters!)
                request.url = URLComponents.url
            }
            else {
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                }
                
                request.httpBody = query(parameters: parameters!).data(using: String.Encoding.utf8, allowLossyConversion: false)
            }
        } else {
            let options = JSONSerialization.WritingOptions()
            
            var data:NSData?
            
            do {
                
                try data = JSONSerialization.data(withJSONObject: parameters!, options: options) as NSData?
                
                if (data != nil) {
                    
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = data as Data?
                    
                }
                
            } catch {
                Log.d("UNABLE TO ENCODE REQUEST")
                return nil
            }
            
        }
        
        return request
    }
    
    private static func query(parameters: [String: Any?]) -> String {
        
        var components: [(String, String)] = []
        
        for key in Array(parameters.keys).sorted(by: <) {
            
            components += queryComponents(key: key, value: parameters[key]!)
            
        }
        
        return (components.map { "\($0)=\($1)" }  as [String] ).joined(separator: "&")
        
    }
    
    public static func encodesParametersInURL(method: HttpMethod) -> Bool {
        switch method {
        case .get, .delete:
            return true
        default:
            return false
        }
    }
    
    private static func queryComponents(key: String, value: Any?) -> [(String, String)] {
        var components: [(String, String)] = []
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(key: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(key: "\(key)[]", value: value)
            }
        } else {
            components.append((escape(string: key), escape(string: "\(String(describing: value))")))
        }
        
        return components
    }
    
    private static func escape(string: String) -> String {
        let generalDelimiters = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimiters = "!$&'()*+,;="
        
        let legalURLCharactersToBeEscaped: CFString = (generalDelimiters + subDelimiters) as CFString
        
        return CFURLCreateStringByAddingPercentEscapes(nil, string as CFString!, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
    
}
