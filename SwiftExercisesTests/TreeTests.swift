//  TreeTests.swift
//  Copyright © 2015 Allen Holub. All rights reserved.
//

import XCTest
@testable import SwiftExercises

class TreeTests: XCTestCase {

    var t: Tree<String>!
    
    override func setUp() {
        super.setUp()
        t = Tree<String>();
    }
    
    override func tearDown() {
        super.tearDown()
        t = nil
    }
    
    func testOneElement() {
        XCTAssertNil( t.smallest() )
        XCTAssertNil( t.largest()  )

        t.add( "x" );

        XCTAssertTrue( t.count      ==  1  )
        XCTAssertTrue( t.smallest() == "x" )
        XCTAssertTrue( t.largest()  == "x" )
    }

    func testBalancedTree() {

        t.add( "d" );
        t.add( "b" );
        t.add( "f" );
        t.add( "a" );
        t.add( "c" );
        t.add( "e" );
        t.add( "g" );

        XCTAssertTrue ( t.findMatchOf("a") == "a" )
        XCTAssertTrue ( t.findMatchOf("b") == "b" )
        XCTAssertTrue ( t.findMatchOf("c") == "c" )
        XCTAssertTrue ( t.findMatchOf("d") == "d" )
        XCTAssertTrue ( t.findMatchOf("e") == "e" )
        XCTAssertTrue ( t.findMatchOf("f") == "f" )
        XCTAssertTrue ( t.findMatchOf("g") == "g" )
        XCTAssertNil  ( t.findMatchOf("h") )
    }

    func testAsString() {
        t += "b"
        t += "a"
        t += "c"
        XCTAssertEqual(t.asString(","), "a,b,c" )
    }

    func testRemove() {
        t.add( "d" );
        t.add( "b" );
        t.add( "f" );
        t.add( "a" );
        t.add( "c" );
        t.add( "e" );
        t.add( "g" );

        XCTAssertEqual(t.asString(""), "abcdefg" )

        t.remove("d");
        XCTAssertEqual(t.asString(""), "abcefg" )

        t.remove("a");
        XCTAssertEqual(t.asString(""), "bcefg" )

        t.remove("g");
        XCTAssertEqual(t.asString(""), "bcef" )
    }

    func testArrayInit() {
        let t: Tree<String> = ["b", "a", "c"]
        XCTAssertEqual(t.asString(""), "abc" )
    }

    func testIterators() {
        let t: Tree<String> = ["b", "a", "c"]

        var s = ""
        for element in t {
            s += element
        }
        XCTAssertEqual( s, "abc" )
    }

    func testSafeTree() {
        let st = SafeTree<MyClass>()

        do {
            let node = MyClass(value:"hello")
            st.add( node )
            try node.modify("goodbye")
            XCTAssert(false, "Shouldn't get here")
        }
        catch LockedObjectException.ObjectLocked {
            // It's actally a success if we get here.
        }
        catch {
            XCTAssert(false, "Shouldn't get here")
        }
    }
}
//----------------------------------------------------------------------
// A class for use as an element in a SafeTree. It has to adopt Lockable
// for the sake of the SafeTree, and it has to adopt Comparable becuase
// all Tree elements have to be comparable.
//
public class MyClass : Comparable, Lockable {

    private var value: String
    private var isLocked = false;

    init( value: String ){ self.value = value }

    public func lock()   { isLocked = true }
    public func unlock() { isLocked = false }

    func modify(newValue: String) throws {
        if isLocked {
            throw LockedObjectException.ObjectLocked
        }
        value = newValue
    }
}

public func == (l: MyClass, r:MyClass ) -> Bool { return l.value == r.value  }
public func <= (l: MyClass, r:MyClass ) -> Bool { return l.value <= r.value  }
public func >= (l: MyClass, r:MyClass ) -> Bool { return l.value >= r.value  }
public func <  (l: MyClass, r:MyClass ) -> Bool { return l.value <  r.value  }
public func >  (l: MyClass, r:MyClass ) -> Bool { return l.value >  r.value  }