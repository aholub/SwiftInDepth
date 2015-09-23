//
//  UndoableTreeTests.swift
//  SwiftExercises
//
//  Created by allen on 9/22/15.
//  Copyright © 2015 allen. All rights reserved.
//

import XCTest
@testable import SwiftExercises

class UndoableTreeTests: XCTestCase {

    func testUndoRedo() {
        let t = UndoableTree<String>()
        t.add("b")
        t.add("a")
        t.add("c"); XCTAssertEqual( asString(t), "abc" );
        t.undo();   XCTAssertEqual( asString(t), "ab" );
        t.undo();   XCTAssertEqual( asString(t), "b" );
        t.redo();   XCTAssertEqual( asString(t), "ab" );
        t.redo();   XCTAssertEqual( asString(t), "abc" );
    }

    func asString(t: UndoableTree<String>) -> String {
        var result = ""
        t.traverse { result += $0; return true }
        return result
    }
}
