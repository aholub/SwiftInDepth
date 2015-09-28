//  TreeTests.swift
//  Copyright © 2015 Allen Holub. All rights reserved.
//

import XCTest
@testable import SwiftExercises

class SafeTreeTests: XCTestCase {

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

class MyClass : Comparable, Lockable {

    private var value: String
    private var isLocked = false;

    init( value: String ){ self.value = value }

    func lock()   { isLocked = true }
    func unlock() { isLocked = false }

    func modify(newValue: String) throws {
        if isLocked {
            throw LockedObjectException.ObjectLocked
        }
        value = newValue
    }
}

func == (l: MyClass, r:MyClass ) -> Bool { return l.value == r.value  }
func <= (l: MyClass, r:MyClass ) -> Bool { return l.value <= r.value  }
func >= (l: MyClass, r:MyClass ) -> Bool { return l.value >= r.value  }
func <  (l: MyClass, r:MyClass ) -> Bool { return l.value <  r.value  }
func >  (l: MyClass, r:MyClass ) -> Bool { return l.value >  r.value  }