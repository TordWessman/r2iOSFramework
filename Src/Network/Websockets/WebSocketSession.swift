//
//  WebsocketSession.swift
//  GardenController
//
//  Created by Tord Wessman on 15/12/16.
//  Copyright © 2016 Axel IT AB. All rights reserved.
//

import Foundation

public class WebSocketSession: ISocketSession {
    
    public static let maxReconnectionAttempts = 10
    public static let webSocketFailedToReConnectErrorCode = 65554
    
    private var m_host: String
    private var m_port: UInt;
    private var m_path: String
    private var m_reconnectionInterval: Int?
    private var m_ws: WebSocket?
    private var m_observers: Array<CanReceiveSessionData>
    private var m_timer: Timer?
    private var m_queue: OperationQueue
    private var m_reconnectionCount: Int
    
    public var address: String { return String(format: "ws://%@:%d%@", m_host, m_port, m_path) }
    public var isConnected: Bool { return m_ws?.readyState == .open }
    private(set) public var error: Error?
    
    public required init (host: String, port: UInt, path: String? = nil) {
        
        m_queue = OperationQueue()
        m_host = host;
        m_port = port;
        m_path = path ?? ""
        m_observers = Array<CanReceiveSessionData>()
        m_reconnectionCount = 0
        
    }
   
    // PRAGMA Mark - public network methods
   
    public func connect() {
        
        m_ws = WebSocket(address)
        
        m_ws?.event.error =  { [weak self] webSocketError in
           
            var error = webSocketError
            
            if (self?.m_reconnectionCount ?? Int.max) > WebSocketSession.maxReconnectionAttempts {
            
                // Did reach maximum retries. Will cease reconnection attempts.
                
                error = NSError(domain: "WebSocketSession", code: WebSocketSession.webSocketFailedToReConnectErrorCode, userInfo: nil)
                
                self?.m_timer?.invalidate()
                self?.m_reconnectionCount = 0
                
            }
            
            self?.m_observers.forEach{ $0.onSessionError(session: self!, error: error as NSError?) }
            self?.m_ws = nil
        }

        m_ws?.event.open = { [weak self] in
            
            self?.error = nil
            self?.m_timer?.invalidate()
            self?.m_observers.forEach{ $0.onSessionConnect(session: self!) }
        
        }
        
        m_ws?.event.close = { [weak self] code, reason, clean in

            self?.m_observers.forEach{ $0.onSessionDisconnect(session: self!) }
            
            if let i = self?.m_reconnectionInterval {
                
                self?.m_timer = Timer.scheduledTimer(timeInterval: TimeInterval(i), target: self!, selector: #selector(self!.reconnect), userInfo: nil, repeats: true)
            
            }

            
        }
        
        m_ws?.event.message = { [weak self] message in

            self?.m_queue.addOperation() {
                
                guard self != nil else { return }
                
                if let msgData = message as? [UInt8], let text = String(data: Data(bytes: msgData), encoding: String.Encoding.utf8), let data = text.data(using: .utf8) {
                    
                    do {
                        
                        let response = try JSONSerialization.jsonObject(with: data) as? Dictionary<String, AnyObject>
                        
                        self!.m_observers.forEach{ $0.onSessionReceive(session: self!, response: response!) }
                        
                    } catch {
                        
                        // TODO serialization Error
                    }
                    
                }

            }
            
        }

    }

    public func disconnect() {
        
        m_ws?.close()
        
        m_timer?.invalidate()
        
    }
    
    public func addObserver(observer: CanReceiveSessionData) {
        
        m_observers.append(observer)
    }
    
    public func send(model: JSONRequest, delegate: InputStream.JsonDictonaryResponseType? ) {
        
        m_queue.addOperation() {
            
            let options = JSONSerialization.WritingOptions()
            
            var data:Data?
            
            do {
                var json = model.json
                
                let keysToRemove = json.keys.filter { json[$0]! == nil }
                
                for key in keysToRemove {
                    json.removeValue(forKey: key)
                }
                
                try data = JSONSerialization.data(withJSONObject: json, options: options)
                
                if let outputString: String = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as String? {
                    
                    self.m_ws?.send(outputString)
                    
                } else {
                    
                    assertionFailure("UNABLE TO CREATE DATA FROM PARAMETERS")
                }
                
            } catch {
                
                assertionFailure("UNABLE TO ENCODE PARAMETERS")
                
            }

        }
        
    }
    
    // Pragma mark - Reconnection timer
    
    public var reconnectionInterval: Int? {
        
        set {
            
            m_reconnectionInterval = newValue
            
        }
        
        get {
            
            return m_reconnectionInterval
        }
    }
    
    @objc func reconnect() {
        
        if !isConnected && m_reconnectionCount < WebSocketSession.maxReconnectionAttempts {
            
            m_reconnectionCount = m_reconnectionCount + 1
            connect()
            
        }
        
    }

}
