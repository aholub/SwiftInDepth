//
//  MedianTests.swift
//  SwiftExercises
//
//  Created by allen on 9/27/15.
//  Copyright © 2015 allen. All rights reserved.
//

import XCTest
@testable import SwiftExercises

class MedianTests: XCTestCase {
    func testMedian() {
        let t = SimpleGenericTree<String>(["a", "b", "c"])
        XCTAssertEqual( t.median(), "b" )
    }

}
