//
//  Console.swift
//  GardenController
//
//  Created by Tord Wessman on 09/01/17.
//  Copyright © 2017 Axel IT AB. All rights reserved.
//

import Foundation

public protocol IConsole {
    
    /*! Did receive messages for a console. */
    var onReceive: (([ConsoleMessage]) -> ())? { get set }
    
    /*! Write to the remote console. */
    func write (text: String)
    
    /*! Calls for a console history fetch. */
    func updateHistory(count: Int)
    
}

public class Console: DeviceBase, IConsole {
    
    public var onReceive: (([ConsoleMessage]) -> ())?
    
    public func write(text: String) {
        
        //super.deviceRouter?.invoke(device: self, action: "InterpretText", parameters: [text]
        super.deviceRouter?.invoke(device: self, action: "InterpretText", parameters: [text], delegate: { [weak self] (json, error) in
            
            guard let message: ConsoleMessage = json?.model(key: DeviceModel.ActionResponse),
                let action: String = json?.parse(key: DeviceModel.Action),
                action == "InterpretText" else { return;  }
            
            self?.onReceive?([message])
            
        })
        
        
    }
    
    public func updateHistory(count: Int) {
        
        super.deviceRouter?.invoke(device: self, action: "GetHistory", parameters: [count])
        
    }
 
    public override func update(json: InputStream.JsonDictionaryType) {

        Log.d("----")
        Log.d(json)
        
        guard let messages: [ConsoleMessage] = json.models(key: DeviceModel.ActionResponse),
            let action: String = json.parse(key: DeviceModel.Action),
            action == "GetHistory" else { return;  }

        

        
        onReceive?(messages)

        super.update(json: json)
        
    }
    
}
