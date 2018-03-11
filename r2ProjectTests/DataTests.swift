//
//  DataTests.swift
//  r2ProjectTests
//
//  Created by Tord Wessman on 2018-03-05.
//  Copyright © 2018 Axel IT AB. All rights reserved.
//

import Foundation
import XCTest
@testable import r2Project

class DataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDataSerialization() {
        
        // 2^32 should set all bits
        XCTAssertEqual([UInt8](repeating: 0xFF, count: 4), Data.serializeValue(UInt32.max))
        XCTAssertEqual([UInt8](repeating: 0xFF, count: 2), Data.serializeValue(UInt16.max))
        
        // only zeros
        XCTAssertEqual([UInt8](repeating: 0x0, count: 4), Data.serializeValue(UInt32.min))

        // LSB first
        XCTAssertEqual([0x42, 0x40], Data.serializeValue(0x40 * 0x100 + 0x42, count: 2))
    
    }
    
    func testStreamExtension() {
    
        let d:[UInt8] = [0x42, 0x40, 0xF0, 0x00]
        let stream1 = InputStream(data: Data(d))
        let stream2 = InputStream(data: Data(d))
        stream1.open()
        stream2.open()
        
        // Should only read the first two bytes
        XCTAssertEqual(UInt16(0x40 * 0x100 + 0x42), try stream1.read(UInt16.self))
        // Stream should have two more bytes
        XCTAssertEqual(UInt16(0xF0), try stream1.read(UInt16.self))
        
        // MONKEY
        let apa = (0xF0 * 0x100) * 0x100
        // Read as UInt32
        XCTAssertEqual(UInt32(apa + 0x40 * 0x100 + 0x42), try stream2.read(UInt32.self))
        
        // Create the test object to serialize
        let katt: InputStream.JsonDictionaryType =  ["ros" : "mos"]
        let payload: InputStream.JsonDictionaryType = ["apa": 42, "katt": katt, "sol": [45,44,43]]
        
        do {
            // Serialize the object
            guard let serialized = Data.serializeObject(payload) else { return XCTFail("Unable to serialize") }
            
            //Create a stream (in order to deserialize it)
            let stream3 = InputStream(data: Data(serialized))
            stream3.open()
            
            // Deserialize the object from the stream
            let deserialized: InputStream.JsonDictionaryType = try stream3.json(serialized.count)
            
            // Test the object members
            XCTAssertEqual(42, deserialized.parse(key: "apa"))
            XCTAssertEqual("mos", deserialized.json(key: "katt")?.parse(key: "ros"))
            
            guard let array: [Int] = deserialized.array(key: "sol") else { return XCTFail("Unable to parse array") }
            
            XCTAssertEqual([45,44,43], array)
            
        } catch {
            print (error)
        }
        
    }
    
    func testPackageFactory() {
        
        let katt: InputStream.JsonDictionaryType =  ["ros" : "mos"]
        let payload: InputStream.JsonDictionaryType = ["apa": 42, "katt": katt, "sol": [45,44,43], "robot": true]
        let headers: InputStream.JsonDictionaryType = ["not": "important?😱"]
        
        let message = TCPMessage(code: 42, payload: payload, destination: "/hund/katt", headers: headers)
        
        let factory = PackageFactory()
        
        guard let serialized = factory.serialize(message: message) else { return XCTFail("Factory Unable to serialize!") }
        
        guard let deserialized = factory.deserailize(data: serialized) else { return XCTFail("Factory Unable to de-serialize!") }
        
        // Test payload
        XCTAssertTrue(message.payload.parse(key: "robot") ?? false)
        XCTAssertEqual(42, deserialized.payload.parse(key: "apa"))
        XCTAssertEqual("mos", deserialized.payload.json(key: "katt")?.parse(key: "ros"))
        guard let array: [Int] = deserialized.payload.array(key: "sol") else { return XCTFail("Unable to parse array") }
        XCTAssertEqual([45,44,43], array)
        
        // Test crazy string in header
        XCTAssertEqual("important?😱", deserialized.headers.parse(key: "not"))
        
        // code
        XCTAssertEqual(42, message.code)
        
        // destination
        XCTAssertEqual("/hund/katt", message.destination)
        
    }
    
}
