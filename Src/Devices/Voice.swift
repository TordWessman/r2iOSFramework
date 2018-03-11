//
//  Voice.swift
//  GardenController
//
//  Created by Tord Wessman on 18/08/15.
//  Copyright (c) 2015 Axel IT AB. All rights reserved.
//

import Foundation

/** Implementations are capable of remote text transfer */
public protocol IVoice: IDevice {
    
    func say(text: String)
    
}

/** RPC Bridge to remote speech synthesizer */
public class Voice: DeviceBase, IVoice {
    
    let SayProperty = "Say"
    
    public func say(text: String) {
        
        deviceRouter?.invoke(device: self, action: SayProperty, parameters: [text])
        
    }
    
}
