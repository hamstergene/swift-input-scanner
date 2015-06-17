//
//  ScannerTests.swift
//  ScannerTests
//
//  Created by Evgeny Khomyakov on 2015-06-15.
//  Copyright © 2015 Evgeny Khomyakov. All rights reserved.
//

import XCTest

class ScannerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEmptyOk() {
        let s = Scanner(string: "")
        XCTAssert(nil == s.readLine())
        XCTAssert(nil == s.readWord())
        XCTAssertEqual(true, s.eof)
    }
    
    func testSimpleWords() {
        let s = Scanner(string: " foo \n bar! \t\r\n bazz ")
        XCTAssertEqual("foo", s.readWord()!)
        XCTAssertEqual("bar!", s.readWord()!)
        XCTAssertEqual("bazz", s.readWord()!)
        XCTAssert(nil == s.readWord())
        XCTAssertEqual(true, s.eof)
    }
    
    func testSimpleLines() {
        let s = Scanner(string: " foo \n bar! \r\n bazz ")
        XCTAssertEqual(" foo ", s.readLine()!)
        XCTAssertEqual(" bar! ", s.readLine()!)
        XCTAssertEqual(" bazz ", s.readLine()!)
        XCTAssert(nil == s.readLine())
        XCTAssertEqual(true, s.eof)
    }
    
    func testSimpleCharacters() {
        let s = Scanner(string: " 1 \n 2:3 ")
        XCTAssertEqual("1", s.readCharacter()!)
        XCTAssertEqual("2", s.readCharacter()!)
        XCTAssertEqual(":", s.readCharacter()!)
        XCTAssertEqual("3", s.readCharacter()!)
    }
    
    func testSimpleInts() {
        let s = Scanner(string: " 1 \n 2A3 111\t7FFe ")
        XCTAssertEqual(1, s.readInt()!)
        XCTAssertEqual(2, s.readInt()!)
        XCTAssertEqual("A", s.readCharacter()!)
        XCTAssertEqual(3, s.readInt()!)
        XCTAssertEqual(7, s.readInt(base: 2)!)
        XCTAssertEqual(32766, s.readInt(base: 16)!)
    }
    
    func testSimpleFloats() {
        let s = Scanner(string: " 0 12 1.5006007008 -309.0851 1e6 -125e-3 12.34e56 ")
        XCTAssertEqual(0, s.readDouble()!)
        XCTAssertEqual(12, s.readDouble()!)
        XCTAssertEqualWithAccuracy(1.5006007008, s.readDouble()!, accuracy: 1e-9)
        XCTAssertEqualWithAccuracy(-309.0851, s.readDouble()!, accuracy: 1e-9)
        XCTAssertEqual(1e6, s.readDouble()!)
        XCTAssertEqual(-125e-3, s.readDouble()!)
        XCTAssertEqualWithAccuracy(12.34e56, s.readDouble()!, accuracy: 1e-9*1e56)
    }
    
    func testNextLine() {
        let s = Scanner(string: "1   b c\n2d e f\n3 g h\n foobar")
        s.nextLine()
        s.nextLine()
        s.nextLine()
        XCTAssertEqual("foobar", s.readWord()!)
    }

}
