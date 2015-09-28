//  Collection.swift
//  Copyright © 2015 Allen Holub. All rights reserved.

import Foundation

/// Note that both add and findMatchOf are risky because they add (and give access to) the
/// object that's used as the "key," which could be a reference objecgt. If you modify
/// that object, you'll break the tree. It would be better to use (and return) a copy.
/// Since swift classes do not extend a universal base class (e.g. Object), there's no
/// way to programmatically determine if something is a value type or a reference type
/// in a generic. You can say "someObject is AnyClass" but that evaluates true for
/// structs as well. Since there's no exception mechanism, you can't try to modify it
/// and catch the error at runtime, either. In order to make findMatchOf optional,
/// it has to go into an @objc base protocol, but it can't be generic in that case
/// (no typealiases are allowed, so the argument and return have to be AnyObject),
//  so you'll loose type safety.

public protocol Collection {
    typealias T

    var count: Int { get }
    
    /// Add an element to the tree. If it's a reference object, it's dangerous to keep
    /// the element around after it's been added. If T adopts Lockable, then the
    /// item is locked when it's added and unlocked when it's removed.
    
    func add( element: T        ) -> Bool
    func remove( lookingFor: T  ) throws -> T?
    
    /// Find a matching element (using Comparable overrides) and return it.
    /// Since this method makes it possible for someone to destroy the
    /// tree's internal structure by modifying the node, this is a dangerous
    /// method to provide. However, it's also ridiculous to require someone
    /// to remove an element from the tree to examine it. Contains() is
    /// safer. You don't have to worry about any of this if the element
    /// is Lockable.
    
    func findMatchOf     ( lookingFor: T         ) -> T?
    func contains        ( lookingFor: T         ) -> Bool
    func traverse        ( iterator: (T)->Bool   )
    func forEveryElement ( iterator: (T)->()     )
}