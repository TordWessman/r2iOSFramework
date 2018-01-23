//
//  IDevice.swift
//  GardenController
//
//  Created by Tord Wessman on 18/12/16.
//  Copyright © 2016 Axel IT AB. All rights reserved.
//

import Foundation

public protocol IDevice {
    
    var id: String { get }
    
    /* Device is ready and connected. */
    var ready: Bool { get }

    /* Force the device to update it's data.*/
    func update()
    
    /* The device has been updated. JSON should contain new data. `json` will contain the properties of the device changed. */
    func update(json: InputStream.JsonDictionaryType)

    /* Add change delegate listeners */
    func onChange(listener: @escaping (IDevice) -> ())

}


extension IDevice {
    
    public var ready: Bool { return true }
    
    public func update(json: InputStream.JsonDictionaryType) {}
    
    public func onChange(listener: @escaping (IDevice) -> ()) {}
    
}
