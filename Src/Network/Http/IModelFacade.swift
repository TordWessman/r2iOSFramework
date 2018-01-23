//
//  IModelFacade.swift
//  GardenController
//
//  Created by Tord Wessman on 22/08/15.
//  Copyright (c) 2015 Axel IT AB. All rights reserved.
//

import Foundation


protocol IModelFacade {
    
    
    func get<T>(params: JSONRequest) -> ModelRequest<T>
    func post<T>(params: JSONRequest) -> ModelRequest<T>
    func put<T>(params: JSONRequest) -> ModelRequest<T>
}
