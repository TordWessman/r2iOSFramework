//
//  ISocketSession.swift
//  GardenController
//
//  Created by Tord Wessman on 07/12/16.
//  Copyright © 2016 Axel IT AB. All rights reserved.
//

import Foundation

/** Optional. Session delegate specifications. */
public protocol CanReceiveSessionData {

    /** Called whenever data was received from host. */
    func onSessionReceive(session: ISocketSession, response: InputStream.JsonDictionaryType)
    
    /** Called whet connection to host is established. */
    func onSessionConnect(session: ISocketSession)
    
    /** Called upon disconnection from host. */
    func onSessionDisconnect(session: ISocketSession)
    
    /** Called whenever an error occured. */
    func onSessionError(session: ISocketSession, error: Error?)
    
}

extension CanReceiveSessionData {
    
    public func onSessionReceive(session: ISocketSession, response: InputStream.JsonDictionaryType) {}
    public func onSessionConnect(session: ISocketSession) { Log.d ("Connected: " + session.address) }
    public func onSessionDisconnect(session: ISocketSession) { Log.d("Disconnected from \(session.address).")  }
    public func onSessionError(session: ISocketSession, error: Error?) {Log.d ("Error: " + session.address + ". Description: " + (error?.localizedDescription ?? "[none]" )) }
    
}

/** Is the intermediate between the application layer and the actual connection (i.e. TCP/Web sockets). Represents an interface to a host capable of interractions through JSONRequest objects. */
public protocol ISocketSession {
    
    /** If set, the server will try to reconnect using this interval upon disconnection. */
    var reconnectionInterval: Int? { get set }
    
    /** The endpoint address of this session. */
    var address: String { get }
    
    /** Returns true if connection is established to host. */
    var isConnected: Bool { get }

    /** Connects to host using the specified parameters. The delegate method will be called with "true" if connection was successfull and "false" otherwise. */
    func connect(_ delegate: ((Bool) -> ())?)
    
    /** Disconnect from host. */
    func disconnect()
    
    /** Adds a CanReceiveSessionData listener which will be notified upon changes. */
    func addObserver(observer: CanReceiveSessionData)
    
    /** Sends the JSONConvertable data to host. `delegate` is called upon reply, but it's is optional since an imediate reply can't allways be expected from host. */
    func send(model: JSONRequest, delegate: InputStream.JsonDictonaryResponseType? )
    
}
