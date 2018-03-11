//
//  ModelFacade.swift
//  StupidMeter
//
//  Created by Tord Wessman on 26/10/14.
//  Copyright (c) 2014 Axel IT AB. All rights reserved.
//

import Foundation

public protocol IRequest {

    var id: String {get}

}

public protocol IModelRequest: IRequest {
    
    associatedtype ModelType: JSONInitializable
    
    func success(delegate : @escaping (ModelType, [String:String]?) ->Void) -> Self
    func fail(delegate : @escaping (OperationFail) ->Void) -> Self
    
}

public class ModelFacade : IModelFacade {

    private var m_baseURL: String
    private var m_queue: OperationQueue
    private var m_requests: [String: IRequest]
    
    public func get<T>(params: JSONRequest) -> ModelRequest<T> {

        let request: ModelRequest<T> = createRequest(params: params, method: HttpMethod.get)
        startOperation(request: request);
        
        return request;
        
    }
    
    public func post<T>(params: JSONRequest) -> ModelRequest<T> {
        
        let request: ModelRequest<T> = createRequest(params: params, method: HttpMethod.post)
        startOperation(request: request);
        return request;
        
    }
    
    public func put<T>(params: JSONRequest) -> ModelRequest<T> {
        
        let request: ModelRequest<T> = createRequest(params: params, method: HttpMethod.put)
        startOperation(request: request);
        return request;
        
    }

    
    public init (baseURL: String) {
        
        m_baseURL = baseURL;
        m_queue = OperationQueue()
        m_requests = [String: IRequest]()
    
    }
    
    func completionHandler<T> (operation: ModelRequest<T>) -> Void {
        
        m_requests.removeValue(forKey: operation.id)
    
    }
    
    private func createRequest<T>(params: JSONRequest, method: HttpMethod) -> ModelRequest<T> {
        
        let request = ModelRequest<T>(
            url: m_baseURL + params.url,
            method: method,
            delegate: self.completionHandler,
            params: params);

        m_requests[request.id] = request
        
        return request
        
    }
    
    private func startOperation(request: ModelRequestExecutionInterface) -> Void {
        
        let operation: ModelOperation = ModelOperation(request: request)
        m_queue.addOperation(operation)
        
    }

}
