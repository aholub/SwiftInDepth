//  Median.swift
//  Copyright © 2015 Allen Holub. All rights reserved.

import Foundation

extension Collection {
    func median() -> T? {
        var i = 0;
        var found : T?

        if( count > 0 ) {
            traverse {
                if( i++ == self.count/2 ) {
                    found = $0
                    return false;
                }
                return true
            }
        }
        return found
    }
}