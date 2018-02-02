//
//  TcpClient.swift
//  gardeny
//
//  Created by Tord Wessman on 31/10/17.
//  Copyright © 2017 Axel IT AB. All rights reserved.
//

import Foundation

internal extension Data {
    
    // Instantiate Data using an InputStream
    init(reading input: InputStream) {

        self.init()

        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        
        while input.hasBytesAvailable {
            
            let read = input.read(buffer, maxLength: bufferSize)
            self.append(buffer, count: read)
        
        }
        
        buffer.deallocate(capacity: bufferSize)
        
    }
    
}

internal extension Stream.Status {
    
    // Unable to fetch this information in a readable way otherwise..
    internal var description: String {
        
        switch self {
            
            case .notOpen: return "notOpen"
            
            case .opening: return "opening"
            
            case .open: return "open"
            
            case .reading: return "reading"
            
            case .writing: return "writing"
            
            case .atEnd: return "atEnd"
            
            case .closed: return "closed"
            
            case .error: return "error"

        }

    }
}

internal class TcpClient: NSObject, StreamDelegate {
    
    public typealias ReceiveDelegateType = ((_ data: Data?, _ error: Error?)->())
    typealias ConnectionDelegateType = ((_ success: Bool, _ error: Error?) ->())
    
    typealias InputStreamType = Unmanaged<CFReadStream>
    typealias OutputStreamType = Unmanaged<CFWriteStream>
    
    private var m_outputStreamRef: OutputStreamType?
    private var m_inputStreamRef: InputStreamType?
    
    private var m_outputStream: OutputStream?
    private var m_inputStream: InputStream?
    
    private var m_host: String
    private var m_port: Int
    private var m_delegate: ReceiveDelegateType?
    
    // Called whenever a connection is successfull (or failing)
    private var m_onConnect: ConnectionDelegateType?
    
    // Will be called whenever an error was identified
    public var onError: ((Error?) -> ())?
    
    // Will be called when the connection is closed
    public var onClose: (() -> ())?
    
    // Will be called if data was received outside a send() call.
    public var onReceive: ReceiveDelegateType?
    
    // Statuses indicating that the there's a connection establised
    private let connectedStatuses: [Stream.Status] = [.open, .opening, .reading, .writing, .atEnd]
    
    public init(host: String, port: Int) {
    
        m_host = host
        m_port = port

    }

    // Returns true if the connection is ready for communication.
    public var isReady: Bool {

        return m_inputStream?.streamStatus == .open && m_outputStream?.streamStatus == .open
        
    }
    
    public var host: String { return m_host }
    
    // Returns true if the connection has been established to host
    public var isConnected: Bool {

        return  connectedStatuses.contains(m_inputStream?.streamStatus ?? .notOpen) &&
                connectedStatuses.contains(m_outputStream?.streamStatus ?? .notOpen)

    }
    
    public override var description: String {
        
        return "TcpClient. Host: \(m_host) Port: \(m_port ). Stream statuses: \(m_outputStream?.streamStatus.description ?? "nil" )/ \(m_inputStream?.streamStatus.description ?? "nil")"
        
    }
    
    public func send(data: Data, delegate: ((_ data: Data?, _ error: Error?)->())? ) {
    
        guard isReady else { return assertionFailure("Connection not ready") }

        m_delegate = delegate
        
        m_outputStream?.write([UInt8](data), maxLength: data.count)
        
    }
    
    public func connect(delegate: ConnectionDelegateType? ) {

        m_onConnect = delegate
        
        Log.d ("Connecting...")
        
        guard let url =  URL(string: m_host), let urlHost = url.host as CFString?  else {
            
            assertionFailure("TCP ERROR: Unable to create url from \(m_host)")
            
            delegate?(false, NetworkError.ConnectionError("TCP ERROR: Unable to create url from \(m_host)"))
            m_onConnect = nil
            return
       
        }
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, urlHost, UInt32(m_port), &m_inputStreamRef, &m_outputStreamRef)
    
        guard let outputStreamRef = m_outputStreamRef else {
        
            assertionFailure("TCP ERROR: The stream was not allocated for \(m_host)")
            delegate?(false, NetworkError.ConnectionError("TCP ERROR: The stream was not allocated for \(m_host)"))
            m_onConnect = nil
            return

        }
        
        if(!CFWriteStreamOpen(outputStreamRef.takeUnretainedValue())) {
            
            Log.d("Unable to open write stream to host: \(m_host) on port: \(m_port)")
            delegate?(false, NetworkError.ConnectionError("Unable to open write stream to host: \(m_host) on port: \(m_port)"))
            m_onConnect = nil
            return
            
        }
        
        m_outputStream = m_outputStreamRef?.takeRetainedValue()
        m_inputStream = m_inputStreamRef?.takeRetainedValue()
        
        guard m_outputStream != nil && m_inputStream != nil else {
            
            Log.d("Unable to create retained streams for host: \(m_host) on port: \(m_port)")
            
            delegate?(false, NetworkError.ConnectionError("Unable to create retained streams for host: \(m_host) on port: \(m_port)"))
            m_onConnect = nil
            
            return
            
        }
        
        m_outputStream?.delegate = self
        m_inputStream?.delegate = self
        
        m_outputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        m_inputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        
        m_outputStream?.open()
        m_inputStream?.open()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            // Put your code which should be executed with a delay here
        })

        // Start the call-delegate-process (delegate will be called when status is .open)
        callDelegate(target: nil)
    }
    
    @objc private func callDelegate(target: Any?) {
        
        // Only call delegate when statuses are .open
        if (isReady) {
            
            m_onConnect?(true, nil)
            m_onConnect = nil
            
        } else if (!isConnected) {
            
            m_onConnect?(false, NetworkError.ConnectionError("Connection failed to change state to .open. \(description)"))
            m_onConnect = nil
            
        } else {
            
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(callDelegate), userInfo: nil, repeats: false)
            
        }

    }
    
    public func disconnect() {
        
        m_inputStream?.remove(from: RunLoop.current, forMode:  RunLoopMode.defaultRunLoopMode)
        m_outputStream?.remove(from: RunLoop.current, forMode:  RunLoopMode.defaultRunLoopMode)
        
        if (m_inputStream?.streamStatus == .notOpen) { m_inputStream?.close() }
        if (m_outputStream?.streamStatus == .notOpen) { m_outputStream?.close() }
        
        m_outputStreamRef?.release()
        m_inputStreamRef?.release()
        
        //m_outputStream = nil
        //m_inputStream = nil
        
    }
    
    public func stream(_ stream: Stream, handle eventCode: Stream.Event) {
        
        if (eventCode == Stream.Event.openCompleted) {
            
        } else if (eventCode == Stream.Event.hasSpaceAvailable && stream == m_outputStream && m_outputStream != nil) {

        } else if (eventCode == Stream.Event.hasBytesAvailable && stream == m_inputStream && m_inputStream != nil) {
            
            var data: Data = Data()
            
            let size = 1024
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)

            while m_inputStream?.hasBytesAvailable == true {
                
                let read = m_inputStream!.read(buffer, maxLength: size)
                
                if (read > 0) {
                    
                        data.append(buffer, count: read)
                    
                } else if (read == -1) {
                    
                    // Read error
                    m_delegate?(data, stream.streamError)
                    m_delegate = nil
                    
                }
                
            }
            
            buffer.deallocate(capacity: size)
            
            if (data.count > 0) {
                
                if (m_delegate == nil) {
                    
                    // The delegate was not set, indicating that this data was sent by the server spontaneously ("not inside a client.send() context"). 
                    onReceive?(data, stream.streamError)
                    
                } else {
                    
                    m_delegate?(data, stream.streamError)
                    m_delegate = nil
                }
                
                
            }
           
        } else if (eventCode == Stream.Event.errorOccurred) {
            
            disconnect()
            onError?(stream.streamError)
            
        } else if (eventCode == Stream.Event.endEncountered) {
            
            disconnect()
            onClose?()
        
        } else {
            
            
        }
    
    }

    
}
