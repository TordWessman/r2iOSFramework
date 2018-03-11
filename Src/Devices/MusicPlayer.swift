//
//  MusicPlayer.swift
//  GardenController
//
//  Created by Tord Wessman on 20/12/16.
//  Copyright © 2016 Axel IT AB. All rights reserved.
//

import Foundation

/** Allows remote playback. */
public protocol IMusicPlayer: IDevice {
    
    /** Initiates playback of a resource named `song`. */
    func play(song: String)
    
}

/** RPC bridge to remote music player. */
public class MusicPlayer: DeviceBase, IMusicPlayer {
    
    let PlayCommand = "Play"
    
    public func play(song: String) {
        
        deviceRouter?.invoke(device: self, action: PlayCommand, parameters: [song], delegate: nil)
        
    }
    
}
