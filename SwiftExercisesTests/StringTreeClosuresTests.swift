//
//  StringTreeClosuresTests.swift
//  SwiftExercises
//
//  Created by allen on 9/27/15.
//  Copyright © 2015 allen. All rights reserved.
//

import XCTest
@testable import SwiftExercises

class StringTreeClosuresTests: XCTestCase {

    var t: StringTreeWithClosures!

    override func setUp() {
        super.setUp()
        t = StringTreeWithClosures( ["d", "b", "f", "a", "c", "e", "g"] )
    }

    func testFilterMapReduce() {
        let result = t.filter{ $0 <= "d" }
                      .map   { return $0.uppercaseString }
                      .reduce("-"){ $0 + $1 }

        XCTAssertEqual(result, "-ABCD")
    }

    func testTraversal() {
        var s = ""
        t.traverse(.Inorder){s += $0; return true}
        XCTAssertEqual(s, "abcdefg" )

        s = ""
        t.traverse(.Preorder){s += $0; return true}
        XCTAssertEqual(s, "dbacfeg")

        s = ""
        t.traverse(.Postorder){s += $0; return true}
        XCTAssertEqual(s, "acbegfd" )

        s = ""
        t.traverse{s += $0; return true}
        XCTAssertEqual(s, "abcdefg" )

        s = ""
        t.traverse {
            if( $0 <= "c") {
                s += $0
                return true // allow traversal to continue
            }
            return false // stop the traversal
        }
        XCTAssertEqual(s, "abc" )

        s = ""
        t.forEveryElement{ s += $0 }
        XCTAssertEqual(s, "abcdefg" )

        XCTAssertEqual(t.asString(","), "a,b,c,d,e,f,g" )
    }

}
