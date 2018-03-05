//
//  Console.swift
//  GardenController
//
//  Created by Tord Wessman on 09/01/17.
//  Copyright © 2017 Axel IT AB. All rights reserved.
//

import Foundation

/** Represents a remote console. The console will output r2Server's log messages and is capable of receiving commands. */
public protocol IConsole {
    
    /** Did receive messages for a console. */
    var onReceive: (([ConsoleMessage]) -> ())? { get set }
    
    /** Write to the remote console. Remote will evaluate the expression */
    func write (text: String)
    
    /** Calls for a console history fetch. */
    func updateHistory(count: Int)
    
}

/** RPC bidge coupled to the r2Server's console instance. Allows dynamic interaction without ssh-access*/
public class Console: DeviceBase, IConsole {
    
    // Action requesting the evaluation of a string into a executable command
    let InterpretCommand = "InterpretText"
    
    // Action requesting the console history
    let GetHistoryCommand = "GetHistory"
    
    public var onReceive: (([ConsoleMessage]) -> ())?
    
    public func write(text: String) {
        
        //super.deviceRouter?.invoke(device: self, action: "InterpretText", parameters: [text]
        super.deviceRouter?.invoke(device: self, action: InterpretCommand, parameters: [text], delegate: { [weak self] (json, error) in
            
            guard let message: ConsoleMessage = json?.model(key: DeviceModel.ActionResponse),
                let action: String = json?.parse(key: DeviceModel.Action),
                action == self?.InterpretCommand else { return;  }
            
            self?.onReceive?([message])
            
        })
        
        
    }
    
    public func updateHistory(count: Int) {
        
        super.deviceRouter?.invoke(device: self, action: GetHistoryCommand, parameters: [count])
        
    }
 
    public override func update(json: InputStream.JsonDictionaryType) {

        Log.d("----")
        Log.d(json)
        
        guard let messages: [ConsoleMessage] = json.models(key: DeviceModel.ActionResponse),
            let action: String = json.parse(key: DeviceModel.Action),
            action == GetHistoryCommand else { return;  }

        

        
        onReceive?(messages)

        super.update(json: json)
        
    }
    
}
