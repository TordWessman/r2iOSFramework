//
//  NetworkOperation.swift
//  StupidMeter
//
//  Created by Tord Wessman on 26/10/14.
//  Copyright (c) 2014 Axel IT AB. All rights reserved.
//

import Foundation

public enum OperationStatus : Int {
    case None = 0
    case Running = 50
    case Success = 200
    case Fail = 100
}

public struct OperationFail {
    
    private(set) public var message: String?;
    
    init (message: String) {
        self.message = message;
    }
}


protocol ModelRequestExecutionInterface {
    func execute () -> Void;
}

/**
*   Operation container. Used since a generic NSOperation overload is unable to execute for some reason
*/
class ModelOperation : Operation {

    private var m_request: ModelRequestExecutionInterface
    
    override func main() -> (){
        m_request.execute();
    }
    
    init(request : ModelRequestExecutionInterface) {
        m_request = request;
    }
}

public enum HttpMethod : String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/**
*   Represents a request used to communicate JSONInitializable data
*   The generic parameter T has the type of the input model
*   The generic parameter K has the type of the output model
*/
public class ModelRequest<T :JSONInitializable> : ModelRequestExecutionInterface, IModelRequest  {
    
    public  typealias ModelType = T
    public typealias OPERATION_DONE = ((ModelRequest) -> ())
    public typealias OPERATION_SUCCESS = (ModelType, [String:String]?) ->Void
    public typealias OPERATION_FAIL = (OperationFail) ->Void
    
    private var m_delegate: OPERATION_DONE
    private var m_method: HttpMethod
    private var m_url: String
    private var m_params: JSONConvertable?
    
    private var m_succesDelegate: OPERATION_SUCCESS?
    private var m_failDelegate: OPERATION_FAIL?
    
    private(set) public var status: OperationStatus = .None
    private(set) var json: [String:Any?]?
    
    private var m_httpRequest: HttpRequest?
    
    private(set) public var id: String
    
    func cancel () {
    
        m_httpRequest?.cancel()
        
    }
    
    func execute () {
        
        Log.d (m_method.rawValue + " " + m_url + " \( String(describing: m_params?.json ?? [:]))")

        status = .Running
        
        m_httpRequest = HttpRequest(url: m_url, method: m_method, data: m_params?.json ).send { [weak self] (response, data, error) -> Void in
            
            guard self != nil else {
                return
            }

            if (response != nil && response?.statusCode == 200 && error == nil && data != nil) {

                do {
                    
                    let jsonDictionary: NSDictionary = try JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary

                    if let jsonResult = jsonDictionary as? [String:AnyObject], let obj = T(json: jsonResult) {
                        
                        self?.json = jsonResult
    
                        self?.status = .Success
                        
                        self?.m_succesDelegate?(obj, response?.allHeaderFields as! [String : String]?)
                       
                    } else {
                        
                        Log.d("UNABLE TO PARSE: \(self?.m_url ?? "nil")")
                        self?.status = .Fail;
                    
                    }
                    
                } catch {
                    
                    Log.d("UNABLE TO DECODE: \(self?.m_url ?? "nil")")
                    
                    self?.status = .Fail;
                }
                
            } else {
                
                Log.d(response.debugDescription)
                
                self?.status = .Fail;
           
                self?.m_failDelegate?( OperationFail (message: self?.getErrorMessage(response: response) ?? "nil"))
            
            }
            
            self?.m_delegate(self!);
        }

    }
    
    private func getErrorMessage(response: HTTPURLResponse?) -> String{
        if(response != nil) {
            return response!.description

        } else {
            return "OOOOPHHS"
        }
    }
    
    /**
    *   urlPath: relative path
    *   method: HTTP method to be used
    *   delegate: OPERATION_DONE delegate to be called after a (successful och failed) operation
    *   params: optional parameters of type T to be used as request input parameters
    */
    public init (url: String, method: HttpMethod, delegate:@escaping OPERATION_DONE, params: JSONConvertable? = nil ) {
        
        m_delegate = delegate;
        m_method = method;
        m_url = url;
        m_params = params;
        id = UUID().uuidString
        
    }
    
     public func success(delegate: @escaping OPERATION_SUCCESS) -> Self {
        
        m_succesDelegate = delegate;

        return self;
    }
    
    public func fail(delegate: @escaping OPERATION_FAIL) -> Self {
        
        m_failDelegate = delegate;
        
        return self;
    }
}
