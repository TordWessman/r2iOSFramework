//
//  Voice.swift
//  GardenController
//
//  Created by Tord Wessman on 18/08/15.
//  Copyright (c) 2015 Axel IT AB. All rights reserved.
//

import Foundation

public protocol IVoice: IDevice {
    
    func say(text: String)
    
}

public class Voice: DeviceBase, IVoice {
    
    public func say(text: String) {
        
        deviceRouter?.invoke(device: self, action: "Say", parameters: [text])
        
    }
    
}
