//  verifyAndTreeEmptyTests.swift
//  Copyright © 2015 Allen Holub. All rights reserved.

import XCTest
@testable import SwiftExercises

class VerifyAndTreeEmptyTests: XCTestCase {

    var t: StringTreeWithVerify! = nil
    
    override func setUp() {
        super.setUp()
        t = StringTreeWithVerify( ["d", "b", "f", "a", "c", "e", "g"] )
    }

    func testTreeStructure() {
        XCTAssertTrue( t._verifyChildren("d", left: "b", right: "f") )
        XCTAssertTrue( t._verifyChildren("b", left: "a", right: "c") )
        XCTAssertTrue( t._verifyChildren("f", left: "e", right: "g") )
        XCTAssertTrue( t._verifyChildren("a", left: nil, right: nil) )
        XCTAssertTrue( t._verifyChildren("c", left: nil, right: nil) )
        XCTAssertTrue( t._verifyChildren("e", left: nil, right: nil) )
        XCTAssertTrue( t._verifyChildren("g", left: nil, right: nil) )

        t.add("h")

        XCTAssertTrue( t._verifyChildren("d", left: "b", right: "f") )
        XCTAssertTrue( t._verifyChildren("b", left: "a", right: "c") )
        XCTAssertTrue( t._verifyChildren("f", left: "e", right: "g") )
        XCTAssertTrue( t._verifyChildren("a", left: nil, right: nil) )
        XCTAssertTrue( t._verifyChildren("c", left: nil, right: nil) )
        XCTAssertTrue( t._verifyChildren("e", left: nil, right: nil) )
        XCTAssertTrue( t._verifyChildren("g", left: nil, right: "h") )
        XCTAssertTrue( t._verifyChildren("h", left: nil, right: nil) )
    }

    func testRemove() {
        try! t.remove("c");
        try! t.remove("b");
        try! t.remove("e");
        try! t.remove("f");
        try! t.remove("d");

        XCTAssertTrue( t.count == 2 )
        XCTAssertTrue( t.contains("a") )
        XCTAssertTrue( t.contains("g") )

        do {
            try t.remove("xxxx")
            XCTFail()
        }
        catch StringTreeWithVerify.Error.Empty {}
        catch { XCTFail() }

        do {
            t.clear()
            try t.remove("xxxx")
            XCTFail()
        }
        catch StringTreeWithVerify.Error.Empty {}
        catch { XCTFail() }
    }
}
