//
//  RemoteLog.swift
//  GardenController
//
//  Created by Tord Wessman on 12/01/17.
//  Copyright © 2017 Axel IT AB. All rights reserved.
//

import Foundation

/** Message types defined py r2Server. */
public enum MessageType: Int {
    case message = 0
    case warning = 1
    case error = 2
    case temp = 3
}

/** r2Server log message representation. */
public protocol IConsoleMessage: StringConvertable {
    
    var text: String? {get}
    var type: MessageType? {get}
    var tag: String?{get}
    var timeStamp: String?{get}
    
}

/** Simplifies the colour output representation of a message. */
public extension IConsoleMessage {
    
    public var color: UIColor {
        
        switch (type!) {
            
        case .message:
            return UIColor.gray
        case .error:
            return UIColor.red
        case .warning:
            return UIColor.orange
        case .temp:
            return UIColor.green
            
        }
    }
}

public struct ConsoleMessage: IConsoleMessage, JSONInitializable {
    
    let MessageProperty = "Message"
    let TypeProperty = "Type"
    let TagProperty = "Tag"
    let TimeStampProperty = "TimeStamp"
    
    private(set) public var text: String?
    private(set) public var type: MessageType?
    private(set) public var tag: String?
    private(set) public var timeStamp: String?
    
    public init (text: String, type: MessageType, tag: String? = nil) {
        
        self.text = text
        self.type = type
        self.tag = tag
        self.timeStamp = String(describing: Date())
        
    }
    
    public init? (json: InputStream.JsonDictionaryType?) {
        
        guard let text: String = json?.parse(key: MessageProperty),
            let rawType: Int = json?.parse(key: TypeProperty),
            let type: MessageType = MessageType(rawValue: rawType) else { return; }
        
        self.type = type
        self.text = text
        tag = json?.parse(key: TagProperty)
        timeStamp = json?.parse(key: TimeStampProperty)
        
    }
    
    public var toString: String { return "[" + (timeStamp ?? "") + "] " + (text ?? "")}
    
}

/** Represents an entity capable of asynchronously receiving ConsoleMessage */
public protocol IRemoteLog {
    
    var onReceive: (([ConsoleMessage]) -> ())? { get set }
    
}

/** RPC bridge to a remote logger. Update events should be received whenever a new logging event occurs on remote. */
public class RemoteLog: DeviceBase, IRemoteLog {
    
    public var onReceive: (([ConsoleMessage]) -> ())?
    
    public override func update(json: InputStream.JsonDictionaryType) {
    
        if let newMessage: ConsoleMessage = json.model(key: DeviceModel.ActionResponse) {
        
            onReceive?([newMessage])
            
            super.update(json: json)
            
        } else if let newMessages: [ConsoleMessage] = json.models(key: DeviceModel.ActionResponse) {
            
            onReceive?(newMessages)
            
            super.update(json: json)
            
        }
        
    }
    
}
