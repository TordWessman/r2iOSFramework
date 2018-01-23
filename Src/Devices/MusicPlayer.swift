//
//  MusicPlayer.swift
//  GardenController
//
//  Created by Tord Wessman on 20/12/16.
//  Copyright © 2016 Axel IT AB. All rights reserved.
//

import Foundation

public protocol IMusicPlayer: IDevice {
    
    func play(song: String)
    
}

public class MusicPlayer: DeviceBase, IMusicPlayer {
    
    public func play(song: String) {
        
        deviceRouter?.invoke(device: self, action: "Play", parameters: [song])
        
    }
    
}
