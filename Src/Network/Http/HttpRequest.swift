//
//  HttpRequest.swift
//  GardenController
//
//  Created by Tord Wessman on 09/11/15.
//  Copyright © 2015 Axel IT AB. All rights reserved.
//

import Foundation

public func ==(lhs: HttpRequest, rhs: HttpRequest) -> Bool {
    return lhs.urlRequest == rhs.urlRequest
}

public class HttpRequest: Equatable {
    
    public typealias OPERATION_DONE = (
        HTTPURLResponse?,
        NSData?,
        NSError?) -> Void;
    
    private(set) var urlRequest: NSURLRequest!
    
    // Task used for the underlying network request
    private var sessionTask: URLSessionTask!
    
    private var session: URLSession!
    
    // Initialization with optional response handler member
    init(url:String, method: HttpMethod, data: [String:Any?]? = nil, usingSession session: URLSession? = nil, usingHeaders headers: [String: String]? = nil) {
        
        let req = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        req.httpMethod = method.rawValue
        
        urlRequest = Encoding.createEncodedRequest(request: req, parameters: data )
        
        headers?.keys.forEach{ urlRequest.setValue( headers![$0]!, forKey: $0) }
        
        self.session = session ?? URLSession.shared
    }
    
    // Executes the request asynchronously. Will always call the delegate (OPERATION_DONE)
    public func send(delegate: @escaping OPERATION_DONE) -> Self {
        
        sessionTask = session.dataTask(with: urlRequest as URLRequest, completionHandler: { (responseData, response, error) -> Void in
            
            if let httpResponse = response as? HTTPURLResponse {
                
                //Log.d (" - - NETWORK \(self.URLRequest.httpMethod!) - - got reply from: \(self.URLRequest.url!) code: \(httpResponse.statusCode)")
                
                delegate(httpResponse, responseData as NSData?, error as NSError?)
                
            } else if (error != nil) {
                
                guard (error as NSError?)?.code != NSURLErrorCancelled else { return }
                
                Log.d (" - - NETWORK \(self.urlRequest.httpMethod!) - - ERROR: got reply from: \(self.urlRequest.url!) error: \(error?.localizedDescription ?? "[no description]")")
                
                delegate (nil, responseData as NSData?, error as NSError?)
                
            } else {
                
                Log.d (" - - NETWORK \(self.urlRequest.httpMethod!) - - ERROR: Unknown error: \(self.urlRequest.url!)")
                
                delegate (nil, nil, NSError(domain: "Network error", code: 0, userInfo: ["Message": "response nil or not of type NSHTTPURLResponse"]))
            }
            
        })
        
        sessionTask.resume()
        
        return self
        
    }
    
    public func cancel() {
        sessionTask.cancel()
    }
    
}
