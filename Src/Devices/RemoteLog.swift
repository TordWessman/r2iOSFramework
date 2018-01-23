//
//  RemoteLog.swift
//  GardenController
//
//  Created by Tord Wessman on 12/01/17.
//  Copyright © 2017 Axel IT AB. All rights reserved.
//

import Foundation


public enum MessageType: Int {
    case message = 0
    case warning = 1
    case error = 2
    case temp = 3
}

public protocol IConsoleMessage: StringConvertable {
    
    var text: String? {get}
    var type: MessageType? {get}
    var tag: String?{get}
    var timeStamp: String?{get}
    
}

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
        
        guard let text: String = json?.parse(key: "Message"),
            let rawType: Int = json?.parse(key: "Type"),
            let type: MessageType = MessageType(rawValue: rawType) else { return; }
        
        self.type = type
        self.text = text
        tag = json?.parse(key: "Tag")
        timeStamp = json?.parse(key: "TimeStamp")
        
    }
    
    public var toString: String { return "[" + (timeStamp ?? "") + "] " + (text ?? "")}
    
}

public protocol IRemoteLog {
    
    var onReceive: (([ConsoleMessage]) -> ())? { get set }
    
}

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
